import 'dart:async';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:foxbit_hiring_test_template/data/helpers/websocket.dart';
import 'package:foxbit_hiring_test_template/domain/entities/quote_entity.dart';
import 'package:foxbit_hiring_test_template/domain/repositories/quote_repository.dart';

class SubscribeQuoteParams {
  final dynamic webSocket;
  final int instrumentId;

  SubscribeQuoteParams({
    required this.webSocket,
    required this.instrumentId,
  });
}

class SubscribeQuoteUseCase extends UseCase<QuoteEntity, SubscribeQuoteParams> {
  final IQuoteRepository repository;

  SubscribeQuoteUseCase(this.repository);

  @override
  Future<Stream<QuoteEntity>> buildUseCaseStream(
      SubscribeQuoteParams? params) async {
    final controller = StreamController<QuoteEntity>();

    try {
      final result = await repository.subscribeToQuote(
        params!.webSocket as FoxbitWebSocket,
        params.instrumentId,
      );

      result.fold(
        (failure) => controller.addError(failure),
        (quote) {
          controller.add(quote);
        },
      );

      // Escuta as atualizações futuras
      repository.getQuoteStream(params.instrumentId).listen(
        (either) {
          either.fold(
            (failure) => controller.addError(failure),
            (quote) => controller.add(quote),
          );
        },
        onError: (e) => controller.addError(e.toString()),
      );
    } catch (e) {
      controller.addError(e);
    }

    return controller.stream;
  }
}
