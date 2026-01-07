import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/dashboard_metrics.dart';
import '../../core/models/position.dart';
import '../../core/providers.dart';
import '../../shared/widgets/app_feedback.dart';
import '../../shared/widgets/allocation_pie_chart.dart';
import '../../shared/widgets/equity_chart.dart';
import '../../shared/widgets/kpi_tile.dart';
import '../../shared/widgets/panel.dart';
import '../../shared/widgets/pnl_breakdown_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 1100;
    final isMedium = width >= 800;
    final positionsStream = ref.watch(positionsStreamProvider);

    return StreamBuilder<DashboardMetrics>(
      stream: ref.watch(dashboardMetricsStreamProvider),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return AppError(message: snapshot.error.toString());
        }
        if (!snapshot.hasData) {
          return const AppLoader(message: 'Connecting to live feed...');
        }
        final m = snapshot.data;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 20 : 12,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  KpiTile(
                    title: 'Total PnL',
                    value: m == null ? '--' : _money(m.totalPnl),
                    subtitle: 'Live (WS)',
                    icon: Icons.auto_graph_outlined,
                    tone: (m?.totalPnl ?? 0) >= 0 ? KpiTone.positive : KpiTone.negative,
                  ),
                  KpiTile(
                    title: 'Realized',
                    value: m == null ? '--' : _money(m.realizedPnl),
                    subtitle: 'Booked',
                    icon: Icons.check_circle_outline,
                    tone: (m?.realizedPnl ?? 0) >= 0 ? KpiTone.positive : KpiTone.negative,
                  ),
                  KpiTile(
                    title: 'Unrealized',
                    value: m == null ? '--' : _money(m.unrealizedPnl),
                    subtitle: 'Open positions',
                    icon: Icons.hourglass_bottom_outlined,
                    tone: (m?.unrealizedPnl ?? 0) >= 0 ? KpiTone.positive : KpiTone.negative,
                  ),
                  KpiTile(
                    title: 'Active Strategies',
                    value: m == null ? '--' : '${m.activeStrategies}',
                    subtitle: 'Running',
                    icon: Icons.bolt_outlined,
                  ),
                  KpiTile(
                    title: 'Open Positions',
                    value: m == null ? '--' : '${m.openPositions}',
                    subtitle: 'Read-only',
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                  KpiTile(
                    title: 'Market',
                    value: m == null ? '--' : m.marketStatus,
                    subtitle: 'Exchange status',
                    icon: Icons.access_time_outlined,
                    tone: (m?.marketStatus ?? 'CLOSED') == 'OPEN' ? KpiTone.positive : KpiTone.neutral,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Panel(
                title: 'Is my money safe right now?',
                actions: [
                  FilledButton.icon(
                    onPressed: m == null
                        ? null
                        : () {
                            ref.read(mockRealtimeProvider).setKillSwitch(!m.killSwitchArmed);
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: (m?.killSwitchArmed ?? false) ? Colors.red.shade700 : null,
                      foregroundColor: (m?.killSwitchArmed ?? false) ? Colors.white : null,
                    ),
                    icon: const Icon(Icons.power_settings_new_outlined),
                    label: Text((m?.killSwitchArmed ?? false) ? 'Kill Switch ARMED' : 'Global Kill Switch'),
                  ),
                ],
                child: Row(
                  children: [
                    Icon(
                      (m?.killSwitchArmed ?? false) ? Icons.warning_amber_outlined : Icons.verified_outlined,
                      color: (m?.killSwitchArmed ?? false) ? Colors.red.shade700 : Colors.green.shade700,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        (m?.killSwitchArmed ?? false)
                            ? 'Trading is blocked by global kill switch.'
                            : 'Monitoring live metrics via WebSocket (mock).',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (isMedium)
                Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Panel(
                            title: 'Equity Curve',
                            child: SizedBox(
                              height: 280,
                              child: EquityChart(points: _mockEquityFrom(m)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: Panel(
                            title: 'PnL Breakdown',
                            child: SizedBox(
                              height: 280,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: PnlBreakdownChart(
                                  realized: m?.realizedPnl ?? 0,
                                  unrealized: m?.unrealizedPnl ?? 0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Panel(
                            title: 'Allocation (by symbol)',
                            child: SizedBox(
                              height: 260,
                              child: StreamBuilder<List<Position>>(
                                stream: positionsStream,
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return AppError(message: snapshot.error.toString());
                                  }
                                  if (!snapshot.hasData) {
                                    return const AppLoader(message: 'Loading allocation...');
                                  }

                                  final weights = _allocationWeights(snapshot.data ?? const <Position>[]);
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: AllocationPieChart(weights: weights),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          flex: 2,
                          child: Panel(
                            title: 'Live Updates',
                            child: _LiveUpdatesHint(),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    Panel(
                      title: 'Equity Curve',
                      child: SizedBox(
                        height: 260,
                        child: EquityChart(points: _mockEquityFrom(m)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Panel(
                      title: 'PnL Breakdown',
                      child: SizedBox(
                        height: 220,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: PnlBreakdownChart(
                            realized: m?.realizedPnl ?? 0,
                            unrealized: m?.unrealizedPnl ?? 0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Panel(
                      title: 'Allocation (by symbol)',
                      child: SizedBox(
                        height: 240,
                        child: StreamBuilder<List<Position>>(
                          stream: positionsStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return AppError(message: snapshot.error.toString());
                            }
                            if (!snapshot.hasData) {
                              return const AppLoader(message: 'Loading allocation...');
                            }

                            final weights = _allocationWeights(snapshot.data ?? const <Position>[]);
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: AllocationPieChart(weights: weights),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Panel(
                      title: 'Live Updates',
                      child: _LiveUpdatesHint(),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  static String _money(double v) {
    final f = NumberFormat.compactCurrency(symbol: '\u20b9');
    final s = f.format(v.abs());
    return v >= 0 ? '+$s' : '-$s';
  }

  static List<double> _mockEquityFrom(DashboardMetrics? m) {
    final base = 100000.0;
    final pnl = m?.totalPnl ?? 0.0;
    final end = base + pnl;
    final points = <double>[];
    for (int i = 0; i < 16; i++) {
      final t = i / 15;
      points.add(base + (end - base) * t);
    }
    return points;
  }

  static Map<String, double> _allocationWeights(List<Position> positions) {
    final map = <String, double>{};
    for (final p in positions) {
      final signedQty = p.side == Side.sell ? -p.qty : p.qty;
      map[p.symbol] = (map[p.symbol] ?? 0) + (signedQty * p.ltp);
    }
    return map;
  }
}

class _LiveUpdatesHint extends StatelessWidget {
  const _LiveUpdatesHint();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Phase-1 rule: live updates via WebSocket only (no polling).\n\n'
      'This project uses a mock WS stream right now. When you share real WS event shapes, we will map them here.',
    );
  }
}
