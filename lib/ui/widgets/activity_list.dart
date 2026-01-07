import 'package:flutter/material.dart';

class ActivityList extends StatelessWidget {
  const ActivityList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final items = <_ActivityItemData>[
      const _ActivityItemData('Order filled', 'BTCUSDT Buy 0.05 @ 44,010', '2m'),
      const _ActivityItemData('Strategy started', 'mean_revert_v3 (paper)', '14m'),
      const _ActivityItemData('Risk check', 'Gross exposure 2.10x (OK)', '34m'),
      const _ActivityItemData('Order canceled', 'AAPL Limit Sell 10 @ 193.00', '1h'),
      const _ActivityItemData('Heartbeat', 'Broker connection stable', '2h'),
    ];

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: theme.colorScheme.outlineVariant,
      ),
      itemBuilder: (context, i) {
        final it = items[i];
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          title: Text(it.title),
          subtitle: Text(it.subtitle),
          trailing: Text(
            it.timeAgo,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }
}

class _ActivityItemData {
  const _ActivityItemData(this.title, this.subtitle, this.timeAgo);

  final String title;
  final String subtitle;
  final String timeAgo;
}
