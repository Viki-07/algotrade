import 'package:flutter/material.dart';

class RiskPage extends StatelessWidget {
  const RiskPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Risk (placeholder)\n\nThis will show limits (max drawdown, max leverage, per-symbol exposure) and breach alerts.',
            style: theme.textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
