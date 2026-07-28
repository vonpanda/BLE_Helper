import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/file_utils.dart';
import '../../../data/models/log_entry.dart';
import '../../../services/log/log_service.dart';
import 'log_event.dart';
import 'log_state.dart';

/// BLoC managing log display, filtering, and export.
class LogBloc extends Bloc<LogEvent, LogState> {
  final LogService _logService;

  LogBloc({
    required LogService logService,
  })  : _logService = logService,
        super(const LogState()) {
    on<LogsRequested>(_onLogsRequested);
    on<LogFilterChanged>(_onLogFilterChanged);
    on<ExportRequested>(_onExportRequested);
    on<ClearLogs>(_onClearLogs);
  }

  Future<void> _onLogsRequested(
    LogsRequested event,
    Emitter<LogState> emit,
  ) async {
    try {
      final List<LogEntry> entries = await _logService.query(event.query);
      final LogStats stats = await _logService.getStats();
      emit(state.copyWith(
        entries: entries,
        query: event.query,
        stats: stats,
      ));
    } catch (e) {
      // Silently handle — logs UI should still render
      emit(state.copyWith(entries: [], query: event.query));
    }
  }

  Future<void> _onLogFilterChanged(
    LogFilterChanged event,
    Emitter<LogState> emit,
  ) async {
    try {
      final List<LogEntry> entries = await _logService.query(event.query);
      emit(state.copyWith(
        entries: entries,
        query: event.query,
      ));
    } catch (_) {
      emit(state.copyWith(query: event.query));
    }
  }

  Future<void> _onExportRequested(
    ExportRequested event,
    Emitter<LogState> emit,
  ) async {
    emit(state.copyWith(exportStatus: LogExportStatus.exporting));

    try {
      final String baseDir = await FileUtils.getAppDocumentsPath();
      final String exportDir = '$baseDir/ble_logs/exports';
      await FileUtils.ensureDirectory(exportDir);

      final String filePath = await FileUtils.generateArchivePath(
        exportDir,
        'ble_logs_export',
        event.format.name.toLowerCase(),
      );

      final String resultPath = await _logService.exportLogs(
        filePath,
        event.format,
        query: event.query,
      );

      emit(state.copyWith(
        exportStatus: LogExportStatus.completed,
        exportFilePath: resultPath,
      ));
    } catch (e) {
      emit(state.copyWith(
        exportStatus: LogExportStatus.failed,
        exportFilePath: null,
      ));
    }
  }

  Future<void> _onClearLogs(
    ClearLogs event,
    Emitter<LogState> emit,
  ) async {
    try {
      await _logService.clearLogs();
      final List<LogEntry> entries = await _logService.query(state.query);
      final LogStats stats = await _logService.getStats();
      emit(state.copyWith(
        entries: entries,
        stats: stats,
      ));
    } catch (_) {}
  }
}
