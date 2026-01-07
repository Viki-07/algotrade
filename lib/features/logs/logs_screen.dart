import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/log_event.dart';
import '../../core/providers.dart';
import '../../shared/widgets/app_feedback.dart';
import '../../shared/widgets/panel.dart';

class LogsScreen extends ConsumerWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<List<LogEvent>>(
      stream: ref.watch(logsStreamProvider),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return AppError(message: snapshot.error.toString());
        }
        if (!snapshot.hasData) {
          return const AppLoader(message: 'Subscribing to logs...');
        }
        final items = snapshot.data ?? const <LogEvent>[];

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Panel(
            title: 'Logs & Alerts',
            child: SizedBox(
              height: 620,
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final e = items[i];
                  final color = switch (e.level) {
                    LogLevel.info => Colors.blue.shade700,
                    LogLevel.warn => Colors.orange.shade800,
                    LogLevel.error => Colors.red.shade700,
                  };
                  return ListTile(
                    dense: true,
                    leading: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    title: Text(e.message),
                    subtitle: Text('${DateFormat.Hms().format(e.timestamp)}  •  ${e.level.name.toUpperCase()}'),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
