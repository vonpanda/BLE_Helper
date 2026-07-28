import 'package:equatable/equatable.dart';

import '../../../data/models/log_entry.dart';

/// Export status for log export operation.
enum LogExportStatus { idle, exporting, completed, failed }

/// State for the LogBloc.
class LogState extends Equatable {
  final List<LogEntry> entries;
  final LogQuery query;
  final LogExportStatus exportStatus;
  final LogStats? stats;
  final String? exportFilePath;

  const LogState({
    this.entries = const [],
    this.query = const LogQuery(),
    this.exportStatus = LogExportStatus.idle,
    this.stats,
    this.exportFilePath,
  });

  LogState copyWith({
    List<LogEntry>? entries,
    LogQuery? query,
    LogExportStatus? exportStatus,
    LogStats? stats,
    String? exportFilePath,
    bool clearStats = false,
    bool clearExportFilePath = false,
  }) {
    return LogState(
      entries: entries ?? this.entries,
      query: query ?? this.query,
      exportStatus: exportStatus ?? this.exportStatus,
      stats: clearStats ? null : (stats ?? this.stats),
      exportFilePath:
          clearExportFilePath ? null : (exportFilePath ?? this.exportFilePath),
    );
  }

  @override
  List<Object?> get props => [
        entries,
        query,
        exportStatus,
        stats,
        exportFilePath,
      ];
}
