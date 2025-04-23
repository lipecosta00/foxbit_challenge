import 'dart:async';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:foxbit_hiring_test_template/data/helpers/websocket.dart';
import 'package:foxbit_hiring_test_template/domain/entities/instrument_entity.dart';
import 'package:foxbit_hiring_test_template/domain/repositories/instrument_repository.dart';

class GetInstrumentsUseCase
    extends UseCase<List<InstrumentEntity>, FoxbitWebSocket> {
  final IInstrumentRepository repository;

  GetInstrumentsUseCase(this.repository);

  @override
  Future<Stream<List<InstrumentEntity>>> buildUseCaseStream(
      FoxbitWebSocket? params,) async {
    final controller = StreamController<List<InstrumentEntity>>();

    try {
      final result = await repository.getInstruments(params!);

      result.fold(
        (failure) => controller.addError(failure),
        (instruments) {
          controller.add(instruments);
          controller.close();
        },
      );
    } catch (e) {
      controller.addError(e);
    }

    return controller.stream;
  }
}
