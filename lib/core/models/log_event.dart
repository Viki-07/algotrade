enum LogLevel { info, warn, error }

class LogEvent {
  const LogEvent({
    required this.timestamp,
    required this.level,
    required this.message,
  });

  final DateTime timestamp;
  final LogLevel level;
  final String message;
}
