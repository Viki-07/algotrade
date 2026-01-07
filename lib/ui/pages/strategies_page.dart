import 'package:flutter/material.dart';

class StrategiesPage extends StatelessWidget {
  const StrategiesPage({super.key});

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
            'Strategies (placeholder)\n\nThis will list your strategies, status, parameters, and controls to start/stop/paper/live.',
            style: theme.textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
