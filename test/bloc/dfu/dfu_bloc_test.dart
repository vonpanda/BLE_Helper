import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ble_helper/bloc/dfu/dfu_bloc.dart';
import 'package:ble_helper/bloc/dfu/dfu_event.dart';
import 'package:ble_helper/bloc/dfu/dfu_state.dart';
import 'package:ble_helper/data/models/dfu_firmware.dart';
import 'package:ble_helper/data/models/log_entry.dart';
import 'package:ble_helper/services/dfu/dfu_manager.dart';
import 'package:ble_helper/services/log/log_service.dart';

// --- Mocks ---

class MockDfuManager extends Mock implements DfuManager {}

class MockLogService extends Mock implements LogService {}

void main() {
  late MockDfuManager mockDfuManager;
  late MockLogService mockLogService;

  const testFirmware = DfuFirmware(
    filePath: '/tmp/firmware_v2.zip',
    fileName: 'firmware_v2.zip',
    fileSize: 500 * 1024,
    chipType: DfuChipType.NORDIC,
    firmwareVersion: '2.0.0',
    isValid: true,
  );

  setUpAll(() {
    registerFallbackValue(LogEntry(
      timestamp: DateTime.now(),
      deviceId: 'fallback',
      eventType: LogEventType.ERROR,
      description: 'fallback',
    ));
    registerFallbackValue(testFirmware);
  });

  setUp(() {
    mockDfuManager = MockDfuManager();
    mockLogService = MockLogService();

    when(() => mockLogService.log(any())).thenAnswer((_) async {});
    when(() => mockDfuManager.startDfu(any(), any())).thenAnswer((_) async {});
    when(() => mockDfuManager.abortDfu()).thenAnswer((_) async {});
    when(() => mockDfuManager.observeProgress())
        .thenAnswer((_) => const Stream.empty());
  });

  group('DfuBloc', () {
    // --- Initial State ---
    test('initial state should be IDLE', () {
      final bloc = DfuBloc(
        dfuManager: mockDfuManager,
        logService: mockLogService,
      );
      expect(bloc.state.processState, DfuProcessState.IDLE);
      expect(bloc.state.progressPercent, 0);
      expect(bloc.state.firmware, isNull);
      expect(bloc.state.errorMessage, isNull);
    });

    // --- FirmwareSelected ---
    blocTest<DfuBloc, DfuState>(
      'should transition to READY when firmware is selected',
      build: () => DfuBloc(
        dfuManager: mockDfuManager,
        logService: mockLogService,
      ),
      act: (bloc) => bloc.add(const FirmwareSelected(firmware: testFirmware)),
      expect: () => [
        isA<DfuState>()
            .having((s) => s.processState, 'state', DfuProcessState.READY)
            .having((s) => s.firmware, 'firmware', testFirmware),
      ],
    );

    // --- DfuStarted ---
    blocTest<DfuBloc, DfuState>(
      'should transition to IN_PROGRESS when DFU starts',
      build: () => DfuBloc(
        dfuManager: mockDfuManager,
        logService: mockLogService,
      ),
      seed: () => const DfuState(
        firmware: testFirmware,
        processState: DfuProcessState.READY,
      ),
      act: (bloc) => bloc.add(const DfuStarted(
        deviceId: 'AA:BB:CC',
        firmware: testFirmware,
      )),
      expect: () => [
        isA<DfuState>()
            .having((s) => s.processState, 'state', DfuProcessState.IN_PROGRESS)
            .having((s) => s.progressPercent, 'progress', 0),
        // Then DFU completes (since startDfu resolves)
        isA<DfuState>()
            .having((s) => s.processState, 'state', DfuProcessState.COMPLETED)
            .having((s) => s.progressPercent, 'progress', 100),
      ],
    );

    blocTest<DfuBloc, DfuState>(
      'should transition to FAILED when DFU start throws',
      build: () => DfuBloc(
        dfuManager: mockDfuManager,
        logService: mockLogService,
      ),
      setUp: () {
        when(() => mockDfuManager.startDfu(any(), any()))
            .thenThrow(Exception('DFU initialization failed'));
      },
      seed: () => const DfuState(
        firmware: testFirmware,
        processState: DfuProcessState.READY,
      ),
      act: (bloc) => bloc.add(const DfuStarted(
        deviceId: 'AA:BB:CC',
        firmware: testFirmware,
      )),
      expect: () => [
        isA<DfuState>().having(
            (s) => s.processState, 'in progress', DfuProcessState.IN_PROGRESS),
        isA<DfuState>()
            .having((s) => s.processState, 'failed', DfuProcessState.FAILED)
            .having((s) => s.errorMessage, 'error msg',
                contains('DFU initialization failed')),
      ],
    );

    // --- DfuProgressUpdated ---
    blocTest<DfuBloc, DfuState>(
      'should update progress percentage',
      build: () => DfuBloc(
        dfuManager: mockDfuManager,
        logService: mockLogService,
      ),
      seed: () => const DfuState(
        firmware: testFirmware,
        processState: DfuProcessState.IN_PROGRESS,
        progressPercent: 30,
      ),
      act: (bloc) => bloc.add(const DfuProgressUpdated(percent: 55)),
      expect: () => [
        isA<DfuState>().having((s) => s.progressPercent, 'progress', 55),
      ],
    );

    // --- DfuCompleted ---
    blocTest<DfuBloc, DfuState>(
      'should transition to COMPLETED with 100%',
      build: () => DfuBloc(
        dfuManager: mockDfuManager,
        logService: mockLogService,
      ),
      act: (bloc) => bloc.add(const DfuCompleted()),
      expect: () => [
        isA<DfuState>()
            .having((s) => s.processState, 'state', DfuProcessState.COMPLETED)
            .having((s) => s.progressPercent, 'progress', 100),
      ],
    );

    // --- DfuFailed ---
    blocTest<DfuBloc, DfuState>(
      'should transition to FAILED with error message',
      build: () => DfuBloc(
        dfuManager: mockDfuManager,
        logService: mockLogService,
      ),
      seed: () => const DfuState(
        firmware: testFirmware,
        processState: DfuProcessState.IN_PROGRESS,
      ),
      act: (bloc) =>
          bloc.add(const DfuFailed(message: 'CRC verification failed')),
      expect: () => [
        isA<DfuState>()
            .having((s) => s.processState, 'state', DfuProcessState.FAILED)
            .having(
                (s) => s.errorMessage, 'error msg', 'CRC verification failed'),
      ],
    );

    // --- DfuAborted ---
    blocTest<DfuBloc, DfuState>(
      'should return to IDLE when DFU is aborted',
      build: () => DfuBloc(
        dfuManager: mockDfuManager,
        logService: mockLogService,
      ),
      seed: () => const DfuState(
        firmware: testFirmware,
        processState: DfuProcessState.IN_PROGRESS,
        progressPercent: 45,
      ),
      act: (bloc) => bloc.add(const DfuAborted()),
      expect: () => [
        isA<DfuState>()
            .having((s) => s.processState, 'state', DfuProcessState.IDLE)
            .having((s) => s.firmware, 'firmware preserved', testFirmware),
      ],
    );

    blocTest<DfuBloc, DfuState>(
      'should handle abort failure',
      build: () => DfuBloc(
        dfuManager: mockDfuManager,
        logService: mockLogService,
      ),
      setUp: () {
        when(() => mockDfuManager.abortDfu())
            .thenThrow(Exception('Cannot abort'));
      },
      seed: () => const DfuState(
        firmware: testFirmware,
        processState: DfuProcessState.IN_PROGRESS,
      ),
      act: (bloc) => bloc.add(const DfuAborted()),
      expect: () => [
        isA<DfuState>()
            .having((s) => s.processState, 'state', DfuProcessState.FAILED)
            .having((s) => s.errorMessage, 'error', contains('Abort failed')),
      ],
    );

    // --- State helpers ---
    test('isReady should be true only in READY state', () {
      expect(const DfuState(processState: DfuProcessState.READY).isReady, true);
      expect(const DfuState(processState: DfuProcessState.IDLE).isReady, false);
    });

    test('isInProgress should be true only in IN_PROGRESS state', () {
      expect(
          const DfuState(processState: DfuProcessState.IN_PROGRESS)
              .isInProgress,
          true);
      expect(const DfuState(processState: DfuProcessState.IDLE).isInProgress,
          false);
    });

    test('isCompleted should be true only in COMPLETED state', () {
      expect(
          const DfuState(processState: DfuProcessState.COMPLETED).isCompleted,
          true);
      expect(const DfuState(processState: DfuProcessState.FAILED).isCompleted,
          false);
    });

    test('isFailed should be true only in FAILED state', () {
      expect(
          const DfuState(processState: DfuProcessState.FAILED).isFailed, true);
      expect(const DfuState(processState: DfuProcessState.COMPLETED).isFailed,
          false);
    });
  });

  group('DfuState', () {
    test('copyWith should preserve values', () {
      const state = DfuState(
        processState: DfuProcessState.IN_PROGRESS,
        progressPercent: 50,
      );
      final copied = state.copyWith();
      expect(copied.processState, DfuProcessState.IN_PROGRESS);
      expect(copied.progressPercent, 50);
    });

    test('copyWith should clear optional fields', () {
      const state = DfuState(
        firmware: testFirmware,
        errorMessage: 'error',
      );
      final cleared = state.copyWith(
        clearFirmware: true,
        clearError: true,
      );
      expect(cleared.firmware, isNull);
      expect(cleared.errorMessage, isNull);
    });

    test('props should contain all fields', () {
      const state = DfuState();
      expect(state.props.length, 4);
    });
  });
}
