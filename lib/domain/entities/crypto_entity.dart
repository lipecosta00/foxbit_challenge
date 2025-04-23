import 'package:foxbit_hiring_test_template/domain/entities/instrument_entity.dart';
import 'package:foxbit_hiring_test_template/domain/entities/quote_entity.dart';

class CryptoEntity {
  final InstrumentEntity instrument;
  final QuoteEntity? quote;

  CryptoEntity({
    required this.instrument,
    this.quote,
  });

  String get name => instrument.product1Symbol;
  String get pair => instrument.product2Symbol;
  int get instrumentId => instrument.instrumentId;
  String get price => quote?.lastTradedPx ??'0.0';
  double get volume => quote?.rolling24HrVolume ?? 0.0;
  double get change => quote?.rolling24HrPxChange ?? 0.0;

  CryptoEntity copyWithQuote(QuoteEntity quote) {
    return CryptoEntity(
      instrument: instrument,
      quote: quote,
    );
  }
}
