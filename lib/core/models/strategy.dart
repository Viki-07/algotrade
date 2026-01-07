enum StrategyStatus { running, stopped }

enum TradeMode { paper, live }

class Strategy {
  const Strategy({
    required this.id,
    required this.name,
    required this.instrument,
    required this.status,
    required this.currentPnl,
  });

  final String id;
  final String name;
  final String instrument;
  final StrategyStatus status;
  final double currentPnl;

  Strategy copyWith({
    String? instrument,
    StrategyStatus? status,
    double? currentPnl,
  }) {
    return Strategy(
      id: id,
      name: name,
      instrument: instrument ?? this.instrument,
      status: status ?? this.status,
      currentPnl: currentPnl ?? this.currentPnl,
    );
  }
}

class StrategyConfig {
  const StrategyConfig({
    required this.instrument,
    required this.quantity,
    required this.stopLossPercent,
    required this.targetPercent,
    required this.mode,
  });

  final String instrument;
  final int quantity;
  final double stopLossPercent;
  final double targetPercent;
  final TradeMode mode;
}
