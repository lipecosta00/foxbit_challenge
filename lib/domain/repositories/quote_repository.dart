import 'package:dartz/dartz.dart';
import 'package:foxbit_hiring_test_template/app/core/error/failures.dart';
import 'package:foxbit_hiring_test_template/data/helpers/websocket.dart';
import 'package:foxbit_hiring_test_template/domain/entities/quote_entity.dart';

abstract class IQuoteRepository {
  /// Inscreve para receber atualizações de cotação de um instrumento
  Future<Either<Failure, QuoteEntity>> subscribeToQuote(
      FoxbitWebSocket ws, int instrumentId);

  /// Stream de cotações para um instrumentId específico
  Stream<Either<Failure, QuoteEntity>> getQuoteStream(int instrumentId);
}
