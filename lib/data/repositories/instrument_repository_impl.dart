import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:foxbit_hiring_test_template/app/core/error/failures.dart';
import 'package:foxbit_hiring_test_template/data/helpers/websocket.dart';
import 'package:foxbit_hiring_test_template/data/models/instrument_model.dart';
import 'package:foxbit_hiring_test_template/domain/entities/instrument_entity.dart';
import 'package:foxbit_hiring_test_template/domain/repositories/instrument_repository.dart';

class InstrumentRepository implements IInstrumentRepository {
  final String _eventName = 'getInstruments';

  @override
  Future<Either<Failure, List<InstrumentEntity>>> getInstruments(
    FoxbitWebSocket ws,
  ) async {
    try {
      ws.send(_eventName, {});

      final message = await ws.stream.firstWhere(
        (message) =>
            message['n'].toString() == _eventName && message['i'] == ws.lastId,
      );

      if (message['o'] == null) {
        return Left(ServerFailure());
      }

      final List<dynamic> instrumentsJson = _parseInstrumentsData(message['o']);

      if (instrumentsJson.isEmpty) {
        return Left(ServerFailure());
      }

      final List<InstrumentEntity> instruments = [];

      for (final json in instrumentsJson) {
        if (json is Map<String, dynamic>) {
          instruments.add(InstrumentModel.fromJson(json));
        }
      }

      return Right(instruments);
    } catch (e) {
      return Left(WebSocketFailure());
    }
  }

  // Método auxiliar para analisar os dados de instrumentos
  List<dynamic> _parseInstrumentsData(dynamic data) {
    if (data is String) {
      try {
        final decoded = json.decode(data);
        if (decoded is List) {
          return decoded;
        }
        return [];
      } catch (_) {
        return [];
      }
    }

    if (data is List) {
      return data;
    }

    return [];
  }
}
