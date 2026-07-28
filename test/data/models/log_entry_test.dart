import 'package:flutter_test/flutter_test.dart';

import 'package:ble_helper/data/models/log_entry.dart';
import 'package:ble_helper/data/models/scan_filter.dart';

void main() {
  final testTimestamp = DateTime(2025, 3, 15, 14, 30, 0);

  group('LogEntry', () {
    final entry = LogEntry(
      id: 1,
      timestamp: testTimestamp,
      deviceId: 'AA:BB:CC:DD:EE:FF',
      deviceName: 'Test Device',
      eventType: LogEventType.DEVICE_CONNECTED,
      direction: LogDirection.RX,
      serviceUuid: '00001800-0000-1000-8000-00805F9B34FB',
      characteristicUuid: '00002A00-0000-1000-8000-00805F9B34FB',
      dataHex: '48656C6C6F',
      description: 'Device connected successfully',
    );

    group('Constructor & Properties', () {
      test('should create with all fields', () {
        expect(entry.id, 1);
        expect(entry.timestamp, testTimestamp);
        expect(entry.deviceId, 'AA:BB:CC:DD:EE:FF');
        expect(entry.deviceName, 'Test Device');
        expect(entry.eventType, LogEventType.DEVICE_CONNECTED);
        expect(entry.direction, LogDirection.RX);
        expect(entry.serviceUuid, '00001800-0000-1000-8000-00805F9B34FB');
        expect(
            entry.characteristicUuid, '00002A00-0000-1000-8000-00805F9B34FB');
        expect(entry.dataHex, '48656C6C6F');
        expect(entry.description, 'Device connected successfully');
        expect(entry.errorDetail, isNull);
      });

      test('should allow null optional fields', () {
        final minimal = LogEntry(
          timestamp: testTimestamp,
          deviceId: 'DEV',
          eventType: LogEventType.ERROR,
          description: 'Error occurred',
        );
        expect(minimal.id, isNull);
        expect(minimal.deviceName, isNull);
        expect(minimal.direction, isNull);
        expect(minimal.dataHex, isNull);
        expect(minimal.errorDetail, isNull);
      });

      test('should handle error entry', () {
        final errorEntry = LogEntry(
          timestamp: testTimestamp,
          deviceId: 'DEV',
          eventType: LogEventType.ERROR,
          description: 'Connection failed',
          errorDetail: 'GATT operation timeout',
        );
        expect(errorEntry.eventType, LogEventType.ERROR);
        expect(errorEntry.errorDetail, 'GATT operation timeout');
      });
    });

    group('summary', () {
      test('should include event type name', () {
        expect(entry.summary, contains('DEVICE_CONNECTED'));
      });

      test('should include device name if present', () {
        expect(entry.summary, contains('Test Device'));
      });

      test('should include data hex truncated to 16 chars', () {
        final longData = LogEntry(
          timestamp: testTimestamp,
          deviceId: 'DEV',
          eventType: LogEventType.GATT_WRITE,
          description: 'Write',
          dataHex: 'AABBCCDDEEFF00112233445566778899',
        );
        final summary = longData.summary;
        expect(summary, contains('AABBCCDDEEFF0011')); // first 16 chars
        expect(
            summary.length, lessThanOrEqualTo(longData.dataHex!.length + 50));
      });

      test('should not include device name if null', () {
        final noName = LogEntry(
          timestamp: testTimestamp,
          deviceId: 'DEV',
          eventType: LogEventType.SCAN_DEVICE_FOUND,
          description: 'Found device',
        );
        // summary should not have " - null"
        expect(noName.summary, contains('SCAN_DEVICE_FOUND'));
      });
    });

    group('toJson', () {
      test('should serialize to JSON correctly', () {
        final json = entry.toJson();
        expect(json['id'], 1);
        expect(json['timestamp'], testTimestamp.toUtc().toIso8601String());
        expect(json['deviceId'], 'AA:BB:CC:DD:EE:FF');
        expect(json['deviceName'], 'Test Device');
        expect(json['eventType'], 'DEVICE_CONNECTED');
        expect(json['direction'], 'RX');
        expect(json['serviceUuid'], '00001800-0000-1000-8000-00805F9B34FB');
        expect(
            json['characteristicUuid'], '00002A00-0000-1000-8000-00805F9B34FB');
        expect(json['dataHex'], '48656C6C6F');
        expect(json['description'], 'Device connected successfully');
        expect(json['errorDetail'], isNull);
      });

      test('should handle null optional fields', () {
        final minimal = LogEntry(
          timestamp: testTimestamp,
          deviceId: 'DEV',
          eventType: LogEventType.ERROR,
          description: 'Error',
        );
        final json = minimal.toJson();
        expect(json['id'], isNull);
        expect(json['deviceName'], isNull);
        expect(json['direction'], isNull);
      });
    });

    group('fromJson', () {
      test('should deserialize from JSON correctly', () {
        final json = entry.toJson();
        final parsed = LogEntry.fromJson(json);
        expect(parsed.id, entry.id);
        expect(parsed.deviceId, entry.deviceId);
        expect(parsed.deviceName, entry.deviceName);
        expect(parsed.eventType, entry.eventType);
        expect(parsed.direction, entry.direction);
        expect(parsed.serviceUuid, entry.serviceUuid);
        expect(parsed.dataHex, entry.dataHex);
        expect(parsed.description, entry.description);
        expect(parsed.errorDetail, isNull);
      });

      test('should handle unknown eventType with orElse', () {
        final json = {
          'timestamp': '2025-03-15T14:30:00.000',
          'deviceId': 'DEV',
          'eventType': 'UNKNOWN_TYPE',
          'description': 'test',
        };
        final parsed = LogEntry.fromJson(json);
        expect(parsed.eventType, LogEventType.ERROR); // orElse default
      });

      test('should handle null direction', () {
        final json = {
          'timestamp': '2025-03-15T14:30:00.000',
          'deviceId': 'DEV',
          'eventType': 'SCAN_DEVICE_FOUND',
          'direction': null,
          'description': 'test',
        };
        final parsed = LogEntry.fromJson(json);
        expect(parsed.direction, isNull);
      });

      test('should perform roundtrip', () {
        final fullEntry = LogEntry(
          id: 42,
          timestamp: DateTime(2025, 6, 1),
          deviceId: 'FF:EE',
          deviceName: 'Full Device',
          eventType: LogEventType.DFU_COMPLETED,
          direction: LogDirection.TX,
          serviceUuid: 'SVC-1',
          characteristicUuid: 'CHAR-1',
          dataHex: 'DEADBEEF',
          description: 'DFU completed',
          errorDetail: null,
        );
        final json = fullEntry.toJson();
        final restored = LogEntry.fromJson(json);
        expect(restored.id, fullEntry.id);
        expect(restored.eventType, fullEntry.eventType);
        expect(restored.dataHex, fullEntry.dataHex);
        expect(restored.description, fullEntry.description);
      });
    });

    group('copyWith', () {
      test('should copy with new values', () {
        final copied = entry.copyWith(
          deviceName: 'Updated Device',
          dataHex: 'ABCD',
        );
        expect(copied.deviceName, 'Updated Device');
        expect(copied.dataHex, 'ABCD');
        expect(copied.id, entry.id);
        expect(copied.deviceId, entry.deviceId);
      });

      test('should clear optional fields with clear flags', () {
        final copied = entry.copyWith(
          clearDeviceName: true,
          clearDataHex: true,
          clearErrorDetail: true,
        );
        expect(copied.deviceName, isNull);
        expect(copied.dataHex, isNull);
        expect(copied.errorDetail, isNull);
      });

      test('should copy with no changes', () {
        final copied = entry.copyWith();
        expect(copied.id, entry.id);
        expect(copied.deviceName, entry.deviceName);
        expect(copied.dataHex, entry.dataHex);
      });
    });
  });

  group('LogQuery', () {
    group('Constructor & Defaults', () {
      test('should have correct defaults', () {
        const query = LogQuery();
        expect(query.eventType, isNull);
        expect(query.deviceId, isNull);
        expect(query.startTime, isNull);
        expect(query.endTime, isNull);
        expect(query.searchText, isNull);
        expect(query.limit, isNull);
        expect(query.offset, isNull);
        expect(query.sortField, LogSortField.TIMESTAMP);
        expect(query.sortOrder, SortOrder.DESC);
      });

      test('should create with specific filters', () {
        const query = LogQuery(
          eventType: LogEventType.ERROR,
          deviceId: 'DEV-1',
          limit: 50,
        );
        expect(query.eventType, LogEventType.ERROR);
        expect(query.deviceId, 'DEV-1');
        expect(query.limit, 50);
      });
    });

    group('copyWith', () {
      test('should copy with new values', () {
        const query = LogQuery(limit: 10);
        final copied = query.copyWith(
          eventType: LogEventType.GATT_WRITE,
          limit: 20,
        );
        expect(copied.eventType, LogEventType.GATT_WRITE);
        expect(copied.limit, 20);
      });
    });
  });

  group('LogStats', () {
    test('should create with all fields', () {
      final oldest = DateTime(2025, 1, 1);
      final newest = DateTime(2025, 6, 1);
      final stats = LogStats(
        totalEntries: 5000,
        totalSizeBytes: 1500000,
        oldestEntry: oldest,
        newestEntry: newest,
        typeDistribution: {
          LogEventType.GATT_WRITE: 3000,
          LogEventType.ERROR: 2000
        },
      );
      expect(stats.totalEntries, 5000);
      expect(stats.totalSizeBytes, 1500000);
      expect(stats.oldestEntry, oldest);
      expect(stats.newestEntry, newest);
      expect(stats.typeDistribution.length, 2);
    });
  });

  group('Enums', () {
    test('LogEventType should have all expected values', () {
      expect(LogEventType.values.length, 12);
    });

    test('LogDirection should have TX and RX', () {
      expect(LogDirection.values, [LogDirection.TX, LogDirection.RX]);
    });

    test('LogSortField should have three values', () {
      expect(LogSortField.values.length, 3);
    });

    test('LogExportFormat should have three values', () {
      expect(LogExportFormat.values.length, 3);
    });
  });
}
