import 'package:flutter/material.dart';

import '../widgets/activity_list.dart';
import '../widgets/equity_chart.dart';
import '../widgets/kpi_card.dart';
import '../widgets/positions_table.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 1100;
    final isMedium = width >= 800;

    final padding = EdgeInsets.symmetric(
      horizontal: isWide ? 20 : 12,
      vertical: 16,
    );

    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              KpiCard(
                title: 'Equity',
                value: '\$152,430.12',
                delta: '+1.42% today',
                icon: Icons.account_balance_outlined,
              ),
              KpiCard(
                title: 'P&L (Today)',
                value: '+\$2,130.55',
                delta: '+0.86%',
                icon: Icons.trending_up_outlined,
                tone: KpiTone.positive,
              ),
              KpiCard(
                title: 'Open Positions',
                value: '7',
                delta: '3 long / 4 short',
                icon: Icons.account_balance_wallet_outlined,
              ),
              KpiCard(
                title: 'Exposure',
                value: '1.34x',
                delta: 'Gross 2.10x',
                icon: Icons.layers_outlined,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isMedium)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(
                  flex: 3,
                  child: _Panel(
                    title: 'Equity Curve',
                    child: SizedBox(height: 280, child: EquityChart()),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _Panel(
                    title: 'Activity',
                    child: SizedBox(height: 280, child: ActivityList()),
                  ),
                ),
              ],
            )
          else
            const Column(
              children: [
                _Panel(
                  title: 'Equity Curve',
                  child: SizedBox(height: 260, child: EquityChart()),
                ),
                SizedBox(height: 12),
                _Panel(
                  title: 'Activity',
                  child: SizedBox(height: 260, child: ActivityList()),
                ),
              ],
            ),
          const SizedBox(height: 12),
          const _Panel(
            title: 'Positions',
            child: PositionsTable(),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
