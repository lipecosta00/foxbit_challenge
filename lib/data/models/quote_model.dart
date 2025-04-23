import 'package:foxbit_hiring_test_template/domain/entities/quote_entity.dart';

class QuoteModel extends QuoteEntity {
  QuoteModel({
    required super.instrumentId,
    required super.lastTradedPx,
    required super.rolling24HrVolume,
    required super.rolling24HrPxChange,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      instrumentId: json['InstrumentId'] as int,
      lastTradedPx: json['LastTradedPx'] as String,
      rolling24HrVolume: (json['Rolling24HrVolume'] as num).toDouble(),
      rolling24HrPxChange: (json['Rolling24HrPxChange'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'InstrumentId': instrumentId,
      'LastTradedPx': lastTradedPx,
      'Rolling24HrVolume': rolling24HrVolume,
      'Rolling24HrPxChange': rolling24HrPxChange,
    };
  }
}
