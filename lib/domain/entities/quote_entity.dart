class QuoteEntity {
  final int instrumentId;
  final String lastTradedPx;
  final double rolling24HrVolume;
  final double rolling24HrPxChange;

  QuoteEntity({
    required this.instrumentId,
    required this.lastTradedPx,
    required this.rolling24HrVolume,
    required this.rolling24HrPxChange,
  });
}
