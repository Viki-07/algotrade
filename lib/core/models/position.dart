enum Side { buy, sell }

class Position {
  const Position({
    required this.symbol,
    required this.side,
    required this.qty,
    required this.avgPrice,
    required this.ltp,
    required this.pnl,
  });

  final String symbol;
  final Side side;
  final double qty;
  final double avgPrice;
  final double ltp;
  final double pnl;
}
