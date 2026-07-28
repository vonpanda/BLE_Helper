import 'package:drift/drift.dart';

import '../database/app_database.dart' as db;
import '../models/log_entry.dart';

/// Repository for CRUD operations on log entries.
class LogRepository {
  final db.AppDatabase _db;

  LogRepository({required db.AppDatabase database}) : _db = database;

  /// Insert a single log entry.
  Future<int> insert(LogEntry entry) async {
    try {
      return await _db.logDao.insertEntry(
        db.LogEntriesCompanion.insert(
          timestamp: entry.timestamp.toUtc().toIso8601String(),
          deviceId: entry.deviceId,
          deviceName: Value(entry.deviceName),
          eventType: entry.eventType.name,
          direction: Value(entry.direction?.name),
          serviceUuid: Value(entry.serviceUuid),
          characteristicUuid: Value(entry.characteristicUuid),
          dataHex: Value(entry.dataHex),
          description: entry.description,
          errorDetail: Value(entry.errorDetail),
        ),
      );
    } catch (_) {
      return -1;
    }
  }

  /// Batch insert multiple log entries.
  Future<void> batchInsert(List<LogEntry> entries) async {
    try {
      final List<db.LogEntriesCompanion> companions = entries.map((entry) {
        return db.LogEntriesCompanion.insert(
          timestamp: entry.timestamp.toUtc().toIso8601String(),
          deviceId: entry.deviceId,
          deviceName: Value(entry.deviceName),
          eventType: entry.eventType.name,
          direction: Value(entry.direction?.name),
          serviceUuid: Value(entry.serviceUuid),
          characteristicUuid: Value(entry.characteristicUuid),
          dataHex: Value(entry.dataHex),
          description: entry.description,
          errorDetail: Value(entry.errorDetail),
        );
      }).toList();
      await _db.logDao.batchInsert(companions);
    } catch (_) {}
  }

  /// Query log entries with the given filters.
  Future<List<LogEntry>> query(LogQuery query) async {
    try {
      final List<db.LogEntry> rows = await _db.logDao.queryFiltered(
        eventType: query.eventType?.name,
        deviceId: query.deviceId,
        searchText: query.searchText,
        startTime: query.startTime,
        endTime: query.endTime,
        limit: query.limit,
        offset: query.offset,
        sortField: query.sortField.name,
        sortOrder: query.sortOrder.name,
      );
      return rows.map(_fromRow).toList();
    } catch (_) {
      return [];
    }
  }

  /// Watch log entries as a Stream for real-time UI updates.
  Stream<List<LogEntry>> watchEntries(LogQuery? query) {
    try {
      return _db.logDao
          .watchEntries(
            eventType: query?.eventType?.name,
            deviceId: query?.deviceId,
            startTime: query?.startTime,
            endTime: query?.endTime,
            limit: query?.limit,
          )
          .map((rows) => rows.map<LogEntry>(_fromRow).toList());
    } catch (_) {
      return Stream.value([]);
    }
  }

  /// Delete entries older than a threshold date.
  Future<int> deleteOlderThan(DateTime threshold) async {
    try {
      return await _db.logDao.deleteOlderThan(threshold);
    } catch (_) {
      return 0;
    }
  }

  /// Delete the oldest N entries.
  Future<int> deleteOldest(int count) async {
    try {
      return await _db.logDao.deleteOldest(count);
    } catch (_) {
      return 0;
    }
  }

  /// Get total number of log entries.
  Future<int> count() async {
    try {
      return await _db.logDao.count();
    } catch (_) {
      return 0;
    }
  }

  /// Estimate total size of log entries in bytes.
  Future<int> totalSize() async {
    try {
      // Approximate: count * avg row size (~300 bytes)
      final int totalCount = await _db.logDao.count();
      return totalCount * 300;
    } catch (_) {
      return 0;
    }
  }

  /// Delete all log entries.
  Future<int> deleteAll() async {
    try {
      return await _db.logDao.deleteAll();
    } catch (_) {
      return 0;
    }
  }

  /// Get log stats (counts by type, oldest/newest timestamps).
  Future<LogStats> getStats() async {
    try {
      final int total = await _db.logDao.count();
      final int size = await totalSize();
      final String? oldest = await _db.logDao.getOldestTimestamp();
      final String? newest = await _db.logDao.getNewestTimestamp();
      final Map<String, int> typeCounts = await _db.logDao.countByType();

      final Map<LogEventType, int> distribution = {};
      for (final entry in typeCounts.entries) {
        final LogEventType? t = _tryParseEventType(entry.key);
        if (t != null) {
          distribution[t] = entry.value;
        }
      }

      return LogStats(
        totalEntries: total,
        totalSizeBytes: size,
        oldestEntry: oldest != null ? DateTime.parse(oldest) : DateTime.now(),
        newestEntry: newest != null ? DateTime.parse(newest) : DateTime.now(),
        typeDistribution: distribution,
      );
    } catch (_) {
      return LogStats(
        totalEntries: 0,
        totalSizeBytes: 0,
        oldestEntry: DateTime.now(),
        newestEntry: DateTime.now(),
        typeDistribution: {},
      );
    }
  }

  /// Convert a Drift row to a [LogEntry] domain model.
  LogEntry _fromRow(db.LogEntry row) {
    return LogEntry(
      id: row.id,
      timestamp: DateTime.parse(row.timestamp).toLocal(),
      deviceId: row.deviceId,
      deviceName: row.deviceName,
      eventType: _tryParseEventType(row.eventType) ?? LogEventType.ERROR,
      direction: row.direction != null
          ? LogDirection.values.firstWhere(
              (e) => e.name == row.direction,
              orElse: () => LogDirection.TX,
            )
          : null,
      serviceUuid: row.serviceUuid,
      characteristicUuid: row.characteristicUuid,
      dataHex: row.dataHex,
      description: row.description,
      errorDetail: row.errorDetail,
    );
  }

  LogEventType? _tryParseEventType(String name) {
    for (final t in LogEventType.values) {
      if (t.name == name) return t;
    }
    return null;
  }
}
