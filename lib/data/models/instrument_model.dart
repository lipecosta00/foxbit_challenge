import 'package:foxbit_hiring_test_template/domain/entities/instrument_entity.dart';

class InstrumentModel extends InstrumentEntity {
  InstrumentModel({
    required super.instrumentId,
    required super.symbol,
    required super.product1Symbol,
    required super.product2Symbol,
    required super.sortIndex,
  });

  factory InstrumentModel.fromJson(Map<String, dynamic> json) {
    return InstrumentModel(
      instrumentId: json['InstrumentId'] as int,
      symbol: json['Symbol'] as String,
      product1Symbol: json['Product1Symbol'] as String,
      product2Symbol: json['Product2Symbol'] as String,
      sortIndex: json['SortIndex'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'InstrumentId': instrumentId,
      'Symbol': symbol,
      'Product1Symbol': product1Symbol,
      'Product2Symbol': product2Symbol,
      'SortIndex': sortIndex,
    };
  }
}
