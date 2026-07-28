import '../../core/extensions/datetime_extension.dart';
import '../../core/utils/file_utils.dart';
import '../../data/models/log_entry.dart';
import '../../data/models/scan_filter.dart';
import '../../data/repositories/log_repository.dart';

/// Worker that checks log storage limits and performs archival/cleanup.
///
/// Triggered on startup and periodically when logs exceed:
/// - maxEntries (default 100,000)
/// - maxSizeBytes (default 100 MB)
class LogCleanupWorker {
  final LogRepository _repository;
  final int _maxEntries;
  final int _maxSizeBytes;

  LogCleanupWorker({
    required LogRepository repository,
    int maxEntries = 100000,
    int maxSizeBytes = 100 * 1024 * 1024,
  })  : _repository = repository,
        _maxEntries = maxEntries,
        _maxSizeBytes = maxSizeBytes;

  /// Check limits and perform cleanup if exceeded.
  /// Returns a path to the archive file if archiving occurred, null otherwise.
  Future<String?> checkAndCleanup() async {
    try {
      final int count = await _repository.count();
      final int size = await _repository.totalSize();

      if (count < _maxEntries && size < _maxSizeBytes) {
        return null; // Within limits, nothing to do
      }

      // Archive old logs before deleting
      final String? archivePath = await _archiveOldLogs();

      // Calculate how many to delete: keep ~80% of max
      final int targetCount = (_maxEntries * 0.8).toInt();
      var toDelete = count - targetCount;
      if (toDelete <= 0 && size >= _maxSizeBytes && count > 0) {
        toDelete = (count * 0.2).ceil();
      }

      if (toDelete > 0) {
        await _deleteOldest(toDelete);
      }

      return archivePath;
    } catch (_) {
      return null;
    }
  }

  /// Archive the oldest log entries to a file before deleting them.
  Future<String?> _archiveOldLogs() async {
    try {
      // Query the oldest batch (up to 10000 entries)
      const LogQuery query = LogQuery(
        limit: 10000,
        sortField: LogSortField.TIMESTAMP,
        sortOrder: SortOrder.ASC,
      );
      final List<LogEntry> oldEntries = await _repository.query(query);

      if (oldEntries.isEmpty) return null;

      // Generate archive file path
      final String baseDir = await FileUtils.getAppDocumentsPath();
      final String archiveDir = '$baseDir/ble_logs/archive';
      final String archivePath = await FileUtils.generateArchivePath(
        archiveDir,
        'ble_logs_archive',
        'txt',
      );

      // Write archive file in TXT format
      final StringBuffer sb = StringBuffer();
      for (final LogEntry entry in oldEntries) {
        sb.writeln(
            '[${entry.timestamp.toDisplayString}] ${entry.eventType.name}');
        sb.writeln('  Device: ${entry.deviceName ?? entry.deviceId}');
        if (entry.direction != null) {
          sb.writeln('  Direction: ${entry.direction!.name}');
        }
        if (entry.serviceUuid != null) {
          sb.writeln('  Service: ${entry.serviceUuid}');
        }
        if (entry.dataHex != null && entry.dataHex!.isNotEmpty) {
          sb.writeln('  Data: ${entry.dataHex}');
        }
        sb.writeln('  ${entry.description}');
        sb.writeln('-');
      }
      await FileUtils.writeFile(archivePath, sb.toString());

      return archivePath;
    } catch (_) {
      return null;
    }
  }

  /// Delete the oldest N log entries.
  Future<void> _deleteOldest(int count) async {
    try {
      // Use the date-based approach for efficiency
      const LogQuery query = LogQuery(
        limit: 1,
        sortField: LogSortField.TIMESTAMP,
        sortOrder: SortOrder.ASC,
      );
      final List<LogEntry> oldest = await _repository.query(query);

      if (oldest.isEmpty) return;

      // Find the threshold timestamp such that we delete roughly `count` entries
      final LogQuery thresholdQuery = LogQuery(
        limit: 1,
        offset: count - 1,
        sortField: LogSortField.TIMESTAMP,
        sortOrder: SortOrder.ASC,
      );
      final List<LogEntry> threshold = await _repository.query(thresholdQuery);

      if (threshold.isNotEmpty) {
        await _repository.deleteOlderThan(threshold.first.timestamp);
      }
    } catch (_) {}
  }
}
