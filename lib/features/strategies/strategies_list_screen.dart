import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/models/strategy.dart';
import '../../core/providers.dart';
import '../../shared/widgets/app_feedback.dart';
import '../../shared/widgets/panel.dart';

class StrategiesListScreen extends ConsumerWidget {
  const StrategiesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final isNarrow = width < 600;

    return StreamBuilder<List<Strategy>>(
      stream: ref.watch(strategiesStreamProvider),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return AppError(message: snapshot.error.toString());
        }
        if (!snapshot.hasData) {
          return const AppLoader(message: 'Loading strategies...');
        }
        final items = snapshot.data ?? const <Strategy>[];

        return SingleChildScrollView(
          padding: EdgeInsets.all(isNarrow ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Panel(
                title: 'Strategy List',
                child: items.isEmpty
                    ? const Text('No strategies yet')
                    : Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final s in items) _StrategyCard(strategy: s),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StrategyCard extends ConsumerWidget {
  const _StrategyCard({required this.strategy});

  final Strategy strategy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isNarrow = width < 600;
    final running = strategy.status == StrategyStatus.running;

    final pnl = strategy.currentPnl;
    final pnlColor = pnl >= 0 ? Colors.green.shade700 : Colors.red.shade700;

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 0, maxWidth: isNarrow ? double.infinity : 420),
      child: Card(
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      strategy.name,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  _StatusChip(running: running),
                ],
              ),
              const SizedBox(height: 8),
              Text('Instrument: ${strategy.instrument}'),
              const SizedBox(height: 6),
              Text(
                'Current PnL: ${NumberFormat.compactCurrency(symbol: "\u20b9").format(pnl)}',
                style: TextStyle(color: pnlColor, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.go('/strategies/${strategy.id}/config');
                      },
                      icon: const Icon(Icons.tune_outlined),
                      label: const Text('Config'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        if (running) {
                          await ref.read(mockRealtimeProvider).stopStrategy(strategy.id);
                        } else {
                          context.go('/strategies/${strategy.id}/config');
                        }
                      },
                      icon: Icon(running ? Icons.pause_outlined : Icons.play_arrow_outlined),
                      label: Text(running ? 'Stop' : 'Start'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.running});

  final bool running;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = running ? Colors.green.shade700 : Colors.red.shade700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(
        running ? 'RUNNING' : 'STOPPED',
        style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }
}
