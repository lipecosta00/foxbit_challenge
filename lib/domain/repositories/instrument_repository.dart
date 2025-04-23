import 'package:dartz/dartz.dart';
import 'package:foxbit_hiring_test_template/app/core/error/failures.dart';
import 'package:foxbit_hiring_test_template/data/helpers/websocket.dart';
import 'package:foxbit_hiring_test_template/domain/entities/instrument_entity.dart';

abstract class IInstrumentRepository {
  /// Retorna a lista de instrumentos disponíveis para negociação
  Future<Either<Failure, List<InstrumentEntity>>> getInstruments(
    FoxbitWebSocket ws,
  );
}
