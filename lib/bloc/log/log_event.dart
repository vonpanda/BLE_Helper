import 'package:equatable/equatable.dart';

import '../../../data/models/log_entry.dart';

/// Base class for all log-related events.
sealed class LogEvent extends Equatable {
  const LogEvent();

  @override
  List<Object?> get props => [];
}

/// Request to fetch/refresh logs with the current query.
class LogsRequested extends LogEvent {
  final LogQuery query;

  const LogsRequested({this.query = const LogQuery()});

  @override
  List<Object?> get props => [query];
}

/// Update the filter/query for log entries.
class LogFilterChanged extends LogEvent {
  final LogQuery query;

  const LogFilterChanged({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Export logs to a file in the specified format.
class ExportRequested extends LogEvent {
  final LogExportFormat format;
  final LogQuery query;

  const ExportRequested({
    required this.format,
    this.query = const LogQuery(),
  });

  @override
  List<Object?> get props => [format, query];
}

/// Clear all log entries.
class ClearLogs extends LogEvent {
  const ClearLogs();
}
