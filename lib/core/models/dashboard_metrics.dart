class DashboardMetrics {
  const DashboardMetrics({
    required this.totalPnl,
    required this.realizedPnl,
    required this.unrealizedPnl,
    required this.activeStrategies,
    required this.openPositions,
    required this.marketStatus,
    required this.killSwitchArmed,
  });

  final double totalPnl;
  final double realizedPnl;
  final double unrealizedPnl;
  final int activeStrategies;
  final int openPositions;
  final String marketStatus;
  final bool killSwitchArmed;

  DashboardMetrics copyWith({
    double? totalPnl,
    double? realizedPnl,
    double? unrealizedPnl,
    int? activeStrategies,
    int? openPositions,
    String? marketStatus,
    bool? killSwitchArmed,
  }) {
    return DashboardMetrics(
      totalPnl: totalPnl ?? this.totalPnl,
      realizedPnl: realizedPnl ?? this.realizedPnl,
      unrealizedPnl: unrealizedPnl ?? this.unrealizedPnl,
      activeStrategies: activeStrategies ?? this.activeStrategies,
      openPositions: openPositions ?? this.openPositions,
      marketStatus: marketStatus ?? this.marketStatus,
      killSwitchArmed: killSwitchArmed ?? this.killSwitchArmed,
    );
  }
}
