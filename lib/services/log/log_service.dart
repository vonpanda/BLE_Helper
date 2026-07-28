import 'dart:convert';

import '../../core/extensions/datetime_extension.dart';
import '../../core/utils/file_utils.dart';
import '../../data/models/log_entry.dart';
import '../../data/models/scan_filter.dart';
import '../../data/repositories/log_repository.dart';
import 'log_cleanup_worker.dart';

/// Concrete implementation of the log service.
/// Manages log writing, querying, exporting, and automatic cleanup.
class LogService {
  final LogRepository _repository;
  final LogCleanupWorker _cleanupWorker;
  final int _maxEntries;

  LogService({
    required LogRepository repository,
    required LogCleanupWorker cleanupWorker,
    int maxEntries = 100000,
  })  : _repository = repository,
        _cleanupWorker = cleanupWorker,
        _maxEntries = maxEntries;

  /// Write a log entry to the database.
  Future<void> log(LogEntry entry) async {
    try {
      await _repository.insert(entry);
      await _checkLimits();
    } catch (_) {
      // Silently fail — logging is non-critical for UX
    }
  }

  /// Query log entries with optional filters.
  Future<List<LogEntry>> query(LogQuery query) async {
    return _repository.query(query);
  }

  /// Export logs to a file in the specified format.
  Future<String> exportLogs(
    String filePath,
    LogExportFormat format, {
    LogQuery? query,
  }) async {
    try {
      final LogQuery exportQuery = (query ?? const LogQuery()).copyWith(
        limit: query?.limit ?? _maxEntries,
        sortField: query?.sortField ?? LogSortField.TIMESTAMP,
        sortOrder: query?.sortOrder ?? SortOrder.ASC,
      );
      final List<LogEntry> entries = await _repository.query(exportQuery);

      String content;
      switch (format) {
        case LogExportFormat.TXT:
          content = _formatAsTxt(entries);
          break;
        case LogExportFormat.CSV:
          content = _formatAsCsv(entries);
          break;
        case LogExportFormat.JSON:
          content = _formatAsJson(entries);
          break;
      }

      await FileUtils.writeFile(filePath, content);
      return filePath;
    } catch (e) {
      rethrow;
    }
  }

  /// Archive old logs to a file and clean the database.
  Future<void> archiveAndClean() async {
    try {
      await _cleanupWorker.checkAndCleanup();
    } catch (_) {}
  }

  /// Archive current logs and then clear the log database.
  Future<void> clearLogs() async {
    try {
      final int count = await _repository.count();
      if (count > 0) {
        try {
          final String baseDir = await FileUtils.getAppDocumentsPath();
          final String archiveDir = '$baseDir/ble_logs/archive';
          final String archivePath = await FileUtils.generateArchivePath(
            archiveDir,
            'ble_logs_clear_archive',
            'txt',
          );
          await exportLogs(
            archivePath,
            LogExportFormat.TXT,
            query: LogQuery(
              limit: _maxEntries,
              sortField: LogSortField.TIMESTAMP,
              sortOrder: SortOrder.ASC,
            ),
          );
        } catch (_) {}
      }
      await _repository.deleteAll();
    } catch (_) {}
  }

  /// Get log statistics.
  Future<LogStats> getStats() async {
    return _repository.getStats();
  }

  /// Observe log entries as a stream for real-time UI updates.
  Stream<List<LogEntry>> observeLogs(LogQuery? query) {
    return _repository.watchEntries(query);
  }

  /// Check if limits are exceeded and trigger cleanup if needed.
  Future<void> _checkLimits() async {
    try {
      final int count = await _repository.count();
      if (count >= _maxEntries) {
        await _cleanupWorker.checkAndCleanup();
      }
    } catch (_) {}
  }

  // --- Formatting Helpers ---

  String _formatAsTxt(List<LogEntry> entries) {
    final StringBuffer sb = StringBuffer();
    sb.writeln('=== BLE Helper Log Export ===');
    sb.writeln('Generated: ${DateTime.now().toLocal().toIso8601String()}');
    sb.writeln('Total Entries: ${entries.length}');
    sb.writeln('=' * 60);
    sb.writeln();

    for (final LogEntry entry in entries) {
      sb.writeln(
          '[${entry.timestamp.toDisplayString}] ${entry.eventType.name}');
      sb.writeln('  Device: ${entry.deviceName ?? entry.deviceId}');
      if (entry.direction != null) {
        sb.writeln('  Direction: ${entry.direction!.name}');
      }
      if (entry.serviceUuid != null) {
        sb.writeln('  Service: ${entry.serviceUuid}');
      }
      if (entry.characteristicUuid != null) {
        sb.writeln('  Characteristic: ${entry.characteristicUuid}');
      }
      if (entry.dataHex != null && entry.dataHex!.isNotEmpty) {
        sb.writeln('  Data: ${entry.dataHex}');
      }
      sb.writeln('  ${entry.description}');
      if (entry.errorDetail != null) {
        sb.writeln('  Error: ${entry.errorDetail}');
      }
      sb.writeln('-');
    }
    return sb.toString();
  }

  String _formatAsCsv(List<LogEntry> entries) {
    final StringBuffer sb = StringBuffer();
    sb.writeln('Timestamp,DeviceID,DeviceName,EventType,Direction,ServiceUUID,'
        'CharacteristicUUID,DataHex,Description,ErrorDetail');

    for (final LogEntry entry in entries) {
      sb.writeln(
        '"${entry.timestamp.toUtc().toIso8601String()}",'
        '"${entry.deviceId}",'
        '"${entry.deviceName ?? ''}",'
        '"${entry.eventType.name}",'
        '"${entry.direction?.name ?? ''}",'
        '"${entry.serviceUuid ?? ''}",'
        '"${entry.characteristicUuid ?? ''}",'
        '"${entry.dataHex ?? ''}",'
        '"${entry.description.replaceAll('"', '""')}",'
        '"${entry.errorDetail?.replaceAll('"', '""') ?? ''}"',
      );
    }
    return sb.toString();
  }

  String _formatAsJson(List<LogEntry> entries) {
    final List<Map<String, dynamic>> list =
        entries.map((e) => e.toJson()).toList();
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(list);
  }
}
