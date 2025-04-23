class InstrumentEntity {
  final int instrumentId;
  final String symbol;
  final String product1Symbol;
  final String product2Symbol;
  final int sortIndex;

  InstrumentEntity({
    required this.instrumentId,
    required this.symbol,
    required this.product1Symbol,
    required this.product2Symbol,
    required this.sortIndex,
  });
}
