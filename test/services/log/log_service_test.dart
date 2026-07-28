import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ble_helper/data/models/log_entry.dart';
import 'package:ble_helper/data/repositories/log_repository.dart';
import 'package:ble_helper/services/log/log_service.dart';
import 'package:ble_helper/services/log/log_cleanup_worker.dart';

// --- Mocks ---

class MockLogRepository extends Mock implements LogRepository {}

class MockLogCleanupWorker extends Mock implements LogCleanupWorker {}

void main() {
  late MockLogRepository mockRepo;
  late MockLogCleanupWorker mockCleanupWorker;

  final testEntry = LogEntry(
    timestamp: DateTime(2025, 1, 15, 10, 30),
    deviceId: 'AA:BB:CC:DD:EE:FF',
    deviceName: 'Test Device',
    eventType: LogEventType.DEVICE_CONNECTED,
    description: 'Device connected',
  );

  final testStats = LogStats(
    totalEntries: 5,
    totalSizeBytes: 1500,
    oldestEntry: DateTime(2025, 1, 1),
    newestEntry: DateTime(2025, 1, 15),
    typeDistribution: {LogEventType.DEVICE_CONNECTED: 5},
  );

  setUpAll(() {
    registerFallbackValue(testEntry);
    registerFallbackValue(const LogQuery());
  });

  setUp(() {
    mockRepo = MockLogRepository();
    mockCleanupWorker = MockLogCleanupWorker();

    when(() => mockRepo.insert(any())).thenAnswer((_) async => 1);
    when(() => mockRepo.query(any())).thenAnswer((_) async => [testEntry]);
    when(() => mockRepo.count()).thenAnswer((_) async => 10);
    when(() => mockRepo.totalSize()).thenAnswer((_) async => 3000);
    when(() => mockRepo.getStats()).thenAnswer((_) async => testStats);
  });

  group('LogService', () {
    test('should insert a log entry', () async {
      final service = LogService(
        repository: mockRepo,
        cleanupWorker: mockCleanupWorker,
      );
      await service.log(testEntry);
      verify(() => mockRepo.insert(any())).called(1);
    });

    test('should silently handle insert error', () async {
      when(() => mockRepo.insert(any())).thenThrow(Exception('DB error'));
      final service = LogService(
        repository: mockRepo,
        cleanupWorker: mockCleanupWorker,
      );
      // Should not throw
      await service.log(testEntry);
    });

    test('should query log entries with filters', () async {
      final service = LogService(
        repository: mockRepo,
        cleanupWorker: mockCleanupWorker,
      );
      const query = LogQuery(
        eventType: LogEventType.DEVICE_CONNECTED,
        limit: 10,
      );
      final results = await service.query(query);
      expect(results.length, 1);
      expect(results.first.eventType, LogEventType.DEVICE_CONNECTED);
      verify(() => mockRepo.query(any())).called(1);
    });

    test('should get log stats', () async {
      final service = LogService(
        repository: mockRepo,
        cleanupWorker: mockCleanupWorker,
      );
      final stats = await service.getStats();
      expect(stats.totalEntries, 5);
      expect(stats.totalSizeBytes, 1500);
      verify(() => mockRepo.getStats()).called(1);
    });

    test('should archive and clean via cleanup worker', () async {
      when(() => mockCleanupWorker.checkAndCleanup())
          .thenAnswer((_) async => '/tmp/archive.txt');
      final service = LogService(
        repository: mockRepo,
        cleanupWorker: mockCleanupWorker,
      );
      await service.archiveAndClean();
      verify(() => mockCleanupWorker.checkAndCleanup()).called(1);
    });

    test('should silently handle archive error', () async {
      when(() => mockCleanupWorker.checkAndCleanup())
          .thenThrow(Exception('Archive failed'));
      final service = LogService(
        repository: mockRepo,
        cleanupWorker: mockCleanupWorker,
      );
      // Should not throw
      await service.archiveAndClean();
    });
  });

  group('LogCleanupWorker', () {
    test('should return null when within limits', () async {
      when(() => mockRepo.count()).thenAnswer((_) async => 100);
      when(() => mockRepo.totalSize()).thenAnswer((_) async => 1024);
      final worker = LogCleanupWorker(
        repository: mockRepo,
        maxEntries: 100000,
        maxSizeBytes: 100 * 1024 * 1024,
      );
      final result = await worker.checkAndCleanup();
      expect(result, isNull);
    });

    test('should trigger cleanup when count exceeds limit', () async {
      when(() => mockRepo.count()).thenAnswer((_) async => 120000);
      when(() => mockRepo.totalSize())
          .thenAnswer((_) async => 50 * 1024 * 1024);
      when(() => mockRepo.query(any())).thenAnswer((_) async => [testEntry]);
      when(() => mockRepo.deleteOlderThan(any()))
          .thenAnswer((_) async => 20000);
      final worker = LogCleanupWorker(
        repository: mockRepo,
        maxEntries: 100000,
        maxSizeBytes: 100 * 1024 * 1024,
      );
      await worker.checkAndCleanup();
      // Should attempt cleanup
      verify(() => mockRepo.deleteOlderThan(any())).called(1);
    });

    test('should trigger cleanup when size exceeds limit', () async {
      when(() => mockRepo.count()).thenAnswer((_) async => 50000);
      when(() => mockRepo.totalSize())
          .thenAnswer((_) async => 150 * 1024 * 1024);
      when(() => mockRepo.query(any())).thenAnswer((_) async => [testEntry]);
      when(() => mockRepo.deleteOlderThan(any()))
          .thenAnswer((_) async => 10000);
      final worker = LogCleanupWorker(
        repository: mockRepo,
        maxEntries: 100000,
        maxSizeBytes: 100 * 1024 * 1024,
      );
      await worker.checkAndCleanup();
      verify(() => mockRepo.deleteOlderThan(any())).called(1);
    });

    test('should handle cleanup error gracefully', () async {
      when(() => mockRepo.count()).thenThrow(Exception('DB error'));
      final worker = LogCleanupWorker(
        repository: mockRepo,
      );
      final result = await worker.checkAndCleanup();
      expect(result, isNull);
    });

    test('should not delete if target count already met', () async {
      // count is 100 = well within 100000 limit
      when(() => mockRepo.count()).thenAnswer((_) async => 100);
      when(() => mockRepo.totalSize()).thenAnswer((_) async => 1024);
      final worker = LogCleanupWorker(
        repository: mockRepo,
      );
      final result = await worker.checkAndCleanup();
      expect(result, isNull);
      verifyNever(() => mockRepo.deleteOlderThan(any()));
    });
  });
}
