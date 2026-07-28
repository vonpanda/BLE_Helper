import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ble_helper/bloc/log/log_bloc.dart';
import 'package:ble_helper/bloc/log/log_event.dart';
import 'package:ble_helper/bloc/log/log_state.dart';
import 'package:ble_helper/data/models/log_entry.dart';
import 'package:ble_helper/services/log/log_service.dart';

// --- Mocks ---

class MockLogService extends Mock implements LogService {}

void main() {
  late MockLogService mockLogService;

  final testEntry = LogEntry(
    id: 1,
    timestamp: DateTime(2025, 1, 1),
    deviceId: 'AA:BB',
    eventType: LogEventType.DEVICE_CONNECTED,
    description: 'Connected',
  );

  final testStats = LogStats(
    totalEntries: 10,
    totalSizeBytes: 3000,
    oldestEntry: DateTime(2025, 1, 1),
    newestEntry: DateTime(2025, 6, 1),
    typeDistribution: {LogEventType.DEVICE_CONNECTED: 10},
  );

  setUpAll(() {
    registerFallbackValue(const LogQuery());
    registerFallbackValue(LogExportFormat.TXT);
    registerFallbackValue(testEntry);
  });

  setUp(() {
    mockLogService = MockLogService();

    when(() => mockLogService.query(any()))
        .thenAnswer((_) async => [testEntry]);
    when(() => mockLogService.getStats()).thenAnswer((_) async => testStats);
    when(() => mockLogService.archiveAndClean()).thenAnswer((_) async {});
    when(() => mockLogService.exportLogs(any(), any()))
        .thenAnswer((_) async => '/tmp/export.txt');
  });

  group('LogBloc', () {
    // --- Initial State ---
    test('initial state should be correct', () {
      final bloc = LogBloc(logService: mockLogService);
      expect(bloc.state, const LogState());
    });

    // --- LogsRequested ---
    blocTest<LogBloc, LogState>(
      'should load logs and stats on LogsRequested',
      build: () => LogBloc(logService: mockLogService),
      act: (bloc) => bloc.add(const LogsRequested()),
      expect: () => [
        isA<LogState>()
            .having((s) => s.entries.length, 'entries count', 1)
            .having((s) => s.stats, 'stats not null', isNotNull)
            .having((s) => s.stats!.totalEntries, 'total entries', 10),
      ],
    );

    blocTest<LogBloc, LogState>(
      'should handle LogsRequested with custom query',
      build: () => LogBloc(logService: mockLogService),
      act: (bloc) => bloc.add(const LogsRequested(
        query: LogQuery(
          eventType: LogEventType.ERROR,
          limit: 50,
        ),
      )),
      expect: () => [
        isA<LogState>()
            .having((s) => s.query.eventType, 'eventType filter',
                LogEventType.ERROR)
            .having((s) => s.query.limit, 'limit', 50),
      ],
    );

    blocTest<LogBloc, LogState>(
      'should handle LogsRequested error gracefully',
      build: () => LogBloc(logService: mockLogService),
      setUp: () {
        when(() => mockLogService.query(any()))
            .thenThrow(Exception('DB error'));
      },
      act: (bloc) => bloc.add(const LogsRequested()),
      expect: () => [
        isA<LogState>().having((s) => s.entries, 'empty entries', isEmpty),
      ],
    );

    // --- LogFilterChanged ---
    blocTest<LogBloc, LogState>(
      'should update entries when filter changes',
      build: () => LogBloc(logService: mockLogService),
      act: (bloc) => bloc.add(const LogFilterChanged(
        query: LogQuery(deviceId: 'DEV-1', limit: 20),
      )),
      expect: () => [
        isA<LogState>()
            .having((s) => s.query.deviceId, 'deviceId', 'DEV-1')
            .having((s) => s.query.limit, 'limit', 20)
            .having((s) => s.entries.length, 'entries count', 1),
      ],
    );

    blocTest<LogBloc, LogState>(
      'should handle LogFilterChanged error gracefully',
      build: () => LogBloc(logService: mockLogService),
      setUp: () {
        when(() => mockLogService.query(any()))
            .thenThrow(Exception('query error'));
      },
      act: (bloc) => bloc.add(const LogFilterChanged(
        query: LogQuery(deviceId: 'NONEXISTENT'),
      )),
      expect: () => [
        isA<LogState>().having(
            (s) => s.query.deviceId, 'deviceId preserved', 'NONEXISTENT'),
      ],
    );

    // --- ExportRequested (skipped: requires Flutter platform channels) ---
    // Note: Export tests are skipped because LogBloc calls FileUtils.getAppDocumentsPath()
    // which requires Flutter platform channels not available in test environment.

    // --- ClearLogs ---
    blocTest<LogBloc, LogState>(
      'should clear logs and refresh',
      build: () => LogBloc(logService: mockLogService),
      act: (bloc) => bloc.add(const ClearLogs()),
      expect: () => [
        isA<LogState>()
            .having((s) => s.entries.length, 'entries count', 1)
            .having((s) => s.stats, 'stats not null', isNotNull),
      ],
      verify: (_) {
        verify(() => mockLogService.archiveAndClean()).called(1);
      },
    );

    blocTest<LogBloc, LogState>(
      'should handle ClearLogs error gracefully',
      build: () => LogBloc(logService: mockLogService),
      setUp: () {
        when(() => mockLogService.archiveAndClean())
            .thenThrow(Exception('Cleanup failed'));
      },
      act: (bloc) => bloc.add(const ClearLogs()),
      // Should not emit any new state on error (caught silently)
      expect: () => [],
    );
  });

  group('LogState', () {
    test('copyWith should preserve values', () {
      const state = LogState(
        entries: [],
        query: LogQuery(limit: 10),
        exportStatus: LogExportStatus.idle,
      );
      final copied = state.copyWith();
      expect(copied.query.limit, 10);
      expect(copied.exportStatus, LogExportStatus.idle);
      expect(copied.entries, isEmpty);
    });

    test('copyWith should clear optional fields', () {
      final state = LogState(
        stats: testStats,
        exportFilePath: '/tmp/export.txt',
      );
      final cleared = state.copyWith(
        clearStats: true,
        clearExportFilePath: true,
      );
      expect(cleared.stats, isNull);
      expect(cleared.exportFilePath, isNull);
    });

    test('props should contain all fields', () {
      const state = LogState();
      expect(state.props.length, 5);
    });
  });
}
