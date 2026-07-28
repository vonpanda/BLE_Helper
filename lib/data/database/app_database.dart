import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'dart:io';

part 'app_database.g.dart';

// ================================================================
// Table Definitions
// ================================================================

/// Log entries table — stores all BLE activity logs.
class LogEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get timestamp => text()();
  TextColumn get deviceId => text()();
  TextColumn get deviceName => text().nullable()();
  TextColumn get eventType => text()();
  TextColumn get direction => text().nullable()();
  TextColumn get serviceUuid => text().nullable()();
  TextColumn get characteristicUuid => text().nullable()();
  TextColumn get dataHex => text().nullable()();
  TextColumn get description => text()();
  TextColumn get errorDetail => text().nullable()();
}

/// Favorite devices table — stores user-favorited BLE devices.
class FavoriteDevices extends Table {
  TextColumn get deviceId => text()();
  TextColumn get name => text()();
  TextColumn get macAddress => text()();
  TextColumn get lastSeen => text()();
  TextColumn get deviceJson => text()(); // Full serialized BleDevice

  @override
  Set<Column> get primaryKey => {deviceId};
}

/// Connection history table — tracks device connection timestamps.
class ConnectionHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text()();
  TextColumn get name => text()();
  TextColumn get macAddress => text()();
  TextColumn get connectedAt => text()();
  TextColumn get disconnectedAt => text().nullable()();
}

// ================================================================
// DAO: Log Data Access
// ================================================================

@DriftAccessor(tables: [LogEntries])
class LogDao extends DatabaseAccessor<AppDatabase> with _$LogDaoMixin {
  LogDao(super.db);

  /// Insert a single log entry.
  Future<int> insertEntry(LogEntriesCompanion entry) {
    return into(logEntries).insert(entry);
  }

  /// Batch insert multiple entries.
  Future<void> batchInsert(List<LogEntriesCompanion> entries) {
    return batch((batch) {
      batch.insertAll(logEntries, entries);
    });
  }

  /// Query entries with optional filters, ordering, and pagination.
  Future<List<LogEntry>> queryFiltered({
    String? eventType,
    String? deviceId,
    String? searchText,
    DateTime? startTime,
    DateTime? endTime,
    int? limit,
    int? offset,
    String sortField = 'timestamp',
    String sortOrder = 'DESC',
  }) {
    Expression<bool> buildFilter(LogEntries e) {
      Expression<bool> filter = const Constant(true);

      if (eventType != null && eventType.isNotEmpty) {
        filter = filter & e.eventType.equals(eventType);
      }
      if (deviceId != null && deviceId.isNotEmpty) {
        filter = filter & e.deviceId.equals(deviceId);
      }
      if (startTime != null) {
        filter = filter &
            e.timestamp
                .isBiggerOrEqualValue(startTime.toUtc().toIso8601String());
      }
      if (endTime != null) {
        filter = filter &
            e.timestamp
                .isSmallerOrEqualValue(endTime.toUtc().toIso8601String());
      }
      return filter;
    }

    Expression<Object>? orderBy;
    OrderingMode ordering = OrderingMode.desc;

    switch (sortField) {
      case 'eventType':
        orderBy = logEntries.eventType;
        break;
      case 'deviceName':
        orderBy = logEntries.deviceName;
        break;
      default:
        orderBy = logEntries.timestamp;
    }

    if (sortOrder.toUpperCase() == 'ASC') {
      ordering = OrderingMode.asc;
    }

    final query = (selectOnly(logEntries)..where(buildFilter(logEntries)));

    query.orderBy([OrderingTerm(expression: orderBy, mode: ordering)]);
    if (limit != null) {
      query.limit(limit, offset: offset);
    }

    return query.map((row) {
      return LogEntry(
        id: row.read(logEntries.id)!,
        timestamp: row.read(logEntries.timestamp)!,
        deviceId: row.read(logEntries.deviceId)!,
        deviceName: row.read(logEntries.deviceName),
        eventType: row.read(logEntries.eventType)!,
        direction: row.read(logEntries.direction),
        serviceUuid: row.read(logEntries.serviceUuid),
        characteristicUuid: row.read(logEntries.characteristicUuid),
        dataHex: row.read(logEntries.dataHex),
        description: row.read(logEntries.description)!,
        errorDetail: row.read(logEntries.errorDetail),
      );
    }).get();
  }

  /// Watch all entries (stream for real-time updates).
  Stream<List<LogEntry>> watchEntries({
    String? eventType,
    String? deviceId,
    DateTime? startTime,
    DateTime? endTime,
    int? limit,
  }) {
    Expression<bool> buildFilter(LogEntries e) {
      Expression<bool> filter = const Constant(true);

      if (eventType != null && eventType.isNotEmpty) {
        filter = filter & e.eventType.equals(eventType);
      }
      if (deviceId != null && deviceId.isNotEmpty) {
        filter = filter & e.deviceId.equals(deviceId);
      }
      if (startTime != null) {
        filter = filter &
            e.timestamp
                .isBiggerOrEqualValue(startTime.toUtc().toIso8601String());
      }
      if (endTime != null) {
        filter = filter &
            e.timestamp
                .isSmallerOrEqualValue(endTime.toUtc().toIso8601String());
      }
      return filter;
    }

    var query = (select(logEntries)
      ..where(buildFilter)
      ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]));

    if (limit != null) {
      query = (select(logEntries)
        ..where(buildFilter)
        ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
        ..limit(limit));
    }

    return query.watch();
  }

  /// Delete entries older than a given date.
  Future<int> deleteOlderThan(DateTime threshold) {
    return (delete(logEntries)
          ..where((t) => t.timestamp
              .isSmallerThanValue(threshold.toUtc().toIso8601String())))
        .go();
  }

  /// Delete the oldest N entries.
  Future<int> deleteOldest(int count) async {
    // Get IDs of oldest entries
    final query = selectOnly(logEntries)
      ..addColumns([logEntries.id])
      ..orderBy([OrderingTerm.asc(logEntries.timestamp)])
      ..limit(count);

    final rows = await query.get();
    final ids = rows.map((row) => row.read(logEntries.id)!).toList();

    if (ids.isEmpty) return 0;
    final idList = ids.join(',');
    await customStatement('DELETE FROM log_entries WHERE id IN ($idList)');
    return ids.length;
  }

  /// Count total entries.
  Future<int> count() {
    final query = selectOnly(logEntries)..addColumns([countAll()]);
    return query.map((row) => row.read(countAll())!).getSingle();
  }

  /// Delete all entries.
  Future<int> deleteAll() {
    return delete(logEntries).go();
  }

  /// Count entries grouped by event type.
  Future<Map<String, int>> countByType() async {
    final rows = await (selectOnly(logEntries)
          ..addColumns([logEntries.eventType, logEntries.id.count()])
          ..groupBy([logEntries.eventType]))
        .get();

    final Map<String, int> result = {};
    for (final row in rows) {
      result[row.read(logEntries.eventType)!] =
          row.read(logEntries.id.count())!;
    }
    return result;
  }

  /// Get the timestamp of the oldest entry.
  Future<String?> getOldestTimestamp() async {
    final query = selectOnly(logEntries)
      ..addColumns([logEntries.timestamp])
      ..orderBy([OrderingTerm.asc(logEntries.timestamp)])
      ..limit(1);
    final rows = await query.get();
    if (rows.isEmpty) return null;
    return rows.first.read(logEntries.timestamp);
  }

  /// Get the timestamp of the newest entry.
  Future<String?> getNewestTimestamp() async {
    final query = selectOnly(logEntries)
      ..addColumns([logEntries.timestamp])
      ..orderBy([OrderingTerm.desc(logEntries.timestamp)])
      ..limit(1);
    final rows = await query.get();
    if (rows.isEmpty) return null;
    return rows.first.read(logEntries.timestamp);
  }

  /// Count entries for a specific device.
  Future<int> countByDeviceId(String deviceId) {
    return (selectOnly(logEntries)
          ..addColumns([logEntries.id.count()])
          ..where(logEntries.deviceId.equals(deviceId)))
        .map((row) => row.read(logEntries.id.count())!)
        .getSingle();
  }
}

// ================================================================
// DAO: Favorite Devices Data Access
// ================================================================

@DriftAccessor(tables: [FavoriteDevices, ConnectionHistory])
class DeviceDao extends DatabaseAccessor<AppDatabase> with _$DeviceDaoMixin {
  DeviceDao(super.db);

  /// Get all favorite devices.
  Future<List<FavoriteDevice>> getAllFavorites() {
    return select(favoriteDevices).get();
  }

  /// Check if a device is in favorites.
  Future<bool> isFavorite(String deviceId) async {
    final count = await (selectOnly(favoriteDevices)
          ..addColumns([favoriteDevices.deviceId.count()])
          ..where(favoriteDevices.deviceId.equals(deviceId)))
        .map((row) => row.read(favoriteDevices.deviceId.count())!)
        .getSingle();
    return count > 0;
  }

  /// Add a device to favorites.
  Future<void> addFavorite(FavoriteDevicesCompanion device) {
    return into(favoriteDevices).insertOnConflictUpdate(device);
  }

  /// Remove a device from favorites.
  Future<int> removeFavorite(String deviceId) {
    return (delete(favoriteDevices)..where((t) => t.deviceId.equals(deviceId)))
        .go();
  }

  /// Record a connection in history.
  Future<int> recordConnection(ConnectionHistoryCompanion entry) {
    return into(connectionHistory).insert(entry);
  }

  /// Update the disconnectedAt time of a connection record.
  Future<void> updateDisconnection(int id, String disconnectedAt) {
    return (update(connectionHistory)..where((t) => t.id.equals(id))).write(
        ConnectionHistoryCompanion(disconnectedAt: Value(disconnectedAt)));
  }

  /// Get the most recent connection record for a device.
  Future<ConnectionHistoryData?> getLastConnection(String deviceId) async {
    final query = select(connectionHistory)
      ..where((t) => t.deviceId.equals(deviceId))
      ..orderBy([(t) => OrderingTerm.desc(t.connectedAt)])
      ..limit(1);
    final rows = await query.get();
    return rows.isNotEmpty ? rows.first : null;
  }

  /// Get connection history, ordered by most recent first.
  Future<List<ConnectionHistoryData>> getConnectionHistory({int? limit}) {
    var query = select(connectionHistory)
      ..orderBy([(t) => OrderingTerm.desc(t.connectedAt)]);
    if (limit != null) {
      query = query..limit(limit);
    }
    return query.get();
  }
}

// ================================================================
// Database Definition
// ================================================================

@DriftDatabase(tables: [
  LogEntries,
  FavoriteDevices,
  ConnectionHistory
], daos: [
  LogDao,
  DeviceDao,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        beforeOpen: (OpeningDetails details) async {
          // Enable WAL mode for better concurrent access
          await customStatement('PRAGMA journal_mode=WAL');
          await customStatement('PRAGMA foreign_keys=ON');
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await _getDbFolder();
    final file = File('$dbFolder/ble_helper.db');

    // Ensure directory exists
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }

    return NativeDatabase.createInBackground(file);
  });
}

Future<String> _getDbFolder() async {
  // Use path_provider for reliable platform paths
  // When used without Flutter (tests), fallback to a temp directory
  try {
    if (Platform.isAndroid || Platform.isIOS) {
      final home = Platform.environment['HOME'] ??
          Platform.environment['USERPROFILE'] ??
          '/tmp';
      return '$home/.ble_helper';
    }
    return '/tmp/ble_helper';
  } catch (_) {
    return '/tmp/ble_helper';
  }
}
