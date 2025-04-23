import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:foxbit_hiring_test_template/app/core/error/failures.dart';
import 'package:foxbit_hiring_test_template/data/helpers/websocket.dart';
import 'package:foxbit_hiring_test_template/data/models/quote_model.dart';
import 'package:foxbit_hiring_test_template/domain/entities/quote_entity.dart';
import 'package:foxbit_hiring_test_template/domain/repositories/quote_repository.dart';
import 'package:rxdart/rxdart.dart';

class QuoteRepository implements IQuoteRepository {
  final String _eventName = 'SubscribeLevel1';
  final Map<int, BehaviorSubject<Either<Failure, QuoteEntity>>> _quoteStreams =
      {};

  @override
  Future<Either<Failure, QuoteEntity>> subscribeToQuote(
    FoxbitWebSocket ws,
    int instrumentId,
  ) async {
    try {
      // Cria o stream se não existir
      _quoteStreams[instrumentId] ??=
          BehaviorSubject<Either<Failure, QuoteEntity>>();

      // Envia a requisição de inscrição
      ws.send(_eventName, {'InstrumentId': instrumentId});

      // Espera pela primeira resposta
      final message = await ws.stream
          .where(
            (message) =>
                message['n'].toString() == _eventName &&
                (message['i'] == ws.lastId ||
                    (_isMapWithInstrumentId(message['o'], instrumentId))),
          )
          .first;

      if (message['o'] == null) {
        final failure = Left<Failure, QuoteEntity>(ServerFailure());
        _quoteStreams[instrumentId]?.add(failure);
        return failure;
      }

      final Map<String, dynamic> quoteJson = _parseMessageContent(message['o']);

      if (quoteJson.isEmpty) {
        final failure = Left<Failure, QuoteEntity>(ServerFailure());
        _quoteStreams[instrumentId]?.add(failure);
        return failure;
      }

      final QuoteEntity quote = QuoteModel.fromJson(quoteJson);
      final result = Right<Failure, QuoteEntity>(quote);

      _quoteStreams[instrumentId]?.add(result);

      // Configura o listener para atualizações futuras
      ws.stream
          .where(
        (message) =>
            message['n'].toString() == _eventName &&
            _isMapWithInstrumentId(message['o'], instrumentId),
      )
          .listen((message) {
        try {
          final Map<String, dynamic> quoteJson =
              _parseMessageContent(message['o']);

          if (quoteJson.isNotEmpty) {
            final QuoteEntity quote = QuoteModel.fromJson(quoteJson);
            _quoteStreams[instrumentId]?.add(Right(quote));
          }
        } catch (e) {
          _quoteStreams[instrumentId]?.add(Left(ServerFailure()));
        }
      });

      return result;
    } catch (e) {
      final failure = Left<Failure, QuoteEntity>(WebSocketFailure());
      _quoteStreams[instrumentId]?.add(failure);
      return failure;
    }
  }

  @override
  Stream<Either<Failure, QuoteEntity>> getQuoteStream(int instrumentId) {
    return _quoteStreams[instrumentId]?.stream ??
        Stream.value(Left(ServerFailure()));
  }

  // Método auxiliar para verificar se message['o'] é um Map que contém o instrumentId desejado
  bool _isMapWithInstrumentId(dynamic data, int instrumentId) {
    if (data is Map) {
      return data['InstrumentId'] == instrumentId;
    }

    if (data is String) {
      try {
        final decoded = json.decode(data);
        return decoded is Map && decoded['InstrumentId'] == instrumentId;
      } catch (_) {
        return false;
      }
    }

    return false;
  }

  // Método auxiliar para analisar o conteúdo da mensagem
  Map<String, dynamic> _parseMessageContent(dynamic content) {
    if (content is String) {
      try {
        final decoded = json.decode(content);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        return <String, dynamic>{};
      } catch (_) {
        return <String, dynamic>{};
      }
    }

    if (content is Map) {
      // Convertemos o Map genérico para Map<String, dynamic>
      return Map<String, dynamic>.from(content);
    }

    return <String, dynamic>{};
  }
}
