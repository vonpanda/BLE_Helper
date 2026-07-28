import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ble_helper/bloc/scan/scan_bloc.dart';
import 'package:ble_helper/bloc/scan/scan_event.dart';
import 'package:ble_helper/bloc/scan/scan_state.dart';
import 'package:ble_helper/data/models/ble_device.dart';
import 'package:ble_helper/data/models/scan_filter.dart';
import 'package:ble_helper/data/models/log_entry.dart';
import 'package:ble_helper/services/ble/ble_service_interface.dart';
import 'package:ble_helper/services/log/log_service.dart';

// --- Mocks ---

class MockBleService extends Mock implements IBleService {}

class MockLogService extends Mock implements LogService {}

// --- Test Helpers ---

BleDevice _testDevice(String id) => BleDevice(
      id: id,
      name: 'Device $id',
      macAddress: id,
      rssi: -50,
      lastSeen: DateTime(2025, 1, 1),
    );

void main() {
  late MockBleService mockBleService;
  late MockLogService mockLogService;

  setUpAll(() {
    registerFallbackValue(const ScanFilter());
    registerFallbackValue(LogEntry(
      timestamp: DateTime.now(),
      deviceId: 'fallback',
      eventType: LogEventType.ERROR,
      description: 'fallback',
    ));
  });

  setUp(() {
    mockBleService = MockBleService();
    mockLogService = MockLogService();

    when(() => mockLogService.log(any())).thenAnswer((_) async {});
    when(() => mockBleService.stopScan()).thenAnswer((_) async {});
  });

  group('ScanBloc', () {
    // --- Initial State ---
    test('initial state should be correct', () {
      final bloc = ScanBloc(
        bleService: mockBleService,
        logService: mockLogService,
      );
      expect(bloc.state, const ScanState());
    });

    // --- ScanStarted ---
    blocTest<ScanBloc, ScanState>(
      'should emit scanning state when scan starts',
      build: () => ScanBloc(
        bleService: mockBleService,
        logService: mockLogService,
      ),
      setUp: () {
        final controller = StreamController<List<BleDevice>>();
        when(() => mockBleService.scanDevices(filter: any(named: 'filter')))
            .thenAnswer((_) => controller.stream);
        // Don't let the stream complete — the bloc listens indefinitely
      },
      act: (bloc) => bloc.add(const ScanStarted()),
      expect: () => [
        const ScanState(
          isScanning: true,
          status: ScanStatus.scanning,
          filter: ScanFilter(),
        ),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'should apply custom filter on scan start',
      build: () => ScanBloc(
        bleService: mockBleService,
        logService: mockLogService,
      ),
      setUp: () {
        final controller = StreamController<List<BleDevice>>();
        when(() => mockBleService.scanDevices(filter: any(named: 'filter')))
            .thenAnswer((_) => controller.stream);
      },
      act: (bloc) => bloc.add(const ScanStarted(
        filter: ScanFilter(nameFilter: 'Test', rssiMin: -70),
      )),
      expect: () => [
        const ScanState(
          isScanning: true,
          status: ScanStatus.scanning,
          filter: ScanFilter(nameFilter: 'Test', rssiMin: -70),
        ),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'should clear existing devices when scan restarts',
      build: () => ScanBloc(
        bleService: mockBleService,
        logService: mockLogService,
      ),
      seed: () => ScanState(
        devices: [_testDevice('AA:BB')],
        isScanning: true,
        status: ScanStatus.scanning,
      ),
      setUp: () {
        when(() => mockBleService.scanDevices(filter: any(named: 'filter')))
            .thenAnswer((_) => const Stream<List<BleDevice>>.empty());
      },
      act: (bloc) => bloc.add(const ScanStarted()),
      expect: () => [
        const ScanState(
          isScanning: true,
          status: ScanStatus.scanning,
          filter: ScanFilter(),
        ),
      ],
      verify: (_) {
        verify(() => mockBleService.stopScan()).called(2);
      },
    );

    blocTest<ScanBloc, ScanState>(
      'should preserve existing devices when requested',
      build: () => ScanBloc(
        bleService: mockBleService,
        logService: mockLogService,
      ),
      seed: () => ScanState(devices: [_testDevice('AA:BB')]),
      setUp: () {
        when(() => mockBleService.scanDevices(filter: any(named: 'filter')))
            .thenAnswer((_) => const Stream<List<BleDevice>>.empty());
      },
      act: (bloc) => bloc.add(const ScanStarted(clearResults: false)),
      expect: () => [
        isA<ScanState>()
            .having((s) => s.isScanning, 'is scanning', true)
            .having((s) => s.status, 'status', ScanStatus.scanning)
            .having((s) => s.devices.length, 'devices length', 1),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'should emit error state when scan throws',
      build: () => ScanBloc(
        bleService: mockBleService,
        logService: mockLogService,
      ),
      setUp: () {
        when(() => mockBleService.scanDevices(filter: any(named: 'filter')))
            .thenThrow(Exception('BLE unavailable'));
      },
      act: (bloc) => bloc.add(const ScanStarted()),
      expect: () => [
        const ScanState(
          isScanning: true,
          status: ScanStatus.scanning,
        ),
        const ScanState(
          isScanning: false,
          status: ScanStatus.error,
          errorMessage: 'Exception: BLE unavailable',
        ),
      ],
    );

    // --- ScanStopped ---
    blocTest<ScanBloc, ScanState>(
      'should emit idle state when scan stops',
      build: () => ScanBloc(
        bleService: mockBleService,
        logService: mockLogService,
      ),
      seed: () =>
          const ScanState(isScanning: true, status: ScanStatus.scanning),
      act: (bloc) => bloc.add(const ScanStopped()),
      expect: () => [
        const ScanState(isScanning: false, status: ScanStatus.idle),
      ],
    );

    // --- FilterChanged ---
    blocTest<ScanBloc, ScanState>(
      'should update filter without restarting scan',
      build: () => ScanBloc(
        bleService: mockBleService,
        logService: mockLogService,
      ),
      seed: () => ScanState(
        devices: [_testDevice('AA:BB'), _testDevice('CC:DD')],
      ),
      act: (bloc) => bloc.add(const FilterChanged(
        filter: ScanFilter(nameFilter: 'Device AA'),
      )),
      expect: () => [
        isA<ScanState>()
            .having((s) => s.filter.nameFilter, 'nameFilter', 'Device AA')
            .having((s) => s.devices.length, 'devices length', 1),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'should apply RSSI filter on filter change',
      build: () => ScanBloc(
        bleService: mockBleService,
        logService: mockLogService,
      ),
      seed: () => ScanState(
        devices: [
          _testDevice('AA:BB').copyWith(rssi: -30),
          _testDevice('CC:DD').copyWith(rssi: -80),
        ],
      ),
      act: (bloc) => bloc.add(const FilterChanged(
        filter: ScanFilter(rssiMin: -50),
      )),
      expect: () => [
        isA<ScanState>()
            .having((s) => s.filter.rssiMin, 'rssiMin', -50)
            .having((s) => s.devices.length, 'devices length', 1)
            .having((s) => s.devices.first.id, 'remaining device', 'AA:BB'),
      ],
    );

    blocTest<ScanBloc, ScanState>(
      'should clear filter when empty filter is set',
      build: () => ScanBloc(
        bleService: mockBleService,
        logService: mockLogService,
      ),
      seed: () => ScanState(
        devices: [_testDevice('AA:BB'), _testDevice('CC:DD')],
        filter: const ScanFilter(nameFilter: 'Old'),
      ),
      act: (bloc) => bloc.add(const FilterChanged(filter: ScanFilter())),
      expect: () => [
        isA<ScanState>()
            .having((s) => s.filter.nameFilter, 'nameFilter is null', isNull)
            .having((s) => s.devices.length, 'all devices', 2),
      ],
    );

    // --- ScanError ---
    blocTest<ScanBloc, ScanState>(
      'should emit error state on ScanError event',
      build: () => ScanBloc(
        bleService: mockBleService,
        logService: mockLogService,
      ),
      act: (bloc) => bloc.add(const ScanError(message: 'Bluetooth disabled')),
      expect: () => [
        const ScanState(
          status: ScanStatus.error,
          errorMessage: 'Bluetooth disabled',
        ),
      ],
    );

    // --- Device filtering in stream ---
    blocTest<ScanBloc, ScanState>(
      'should add new devices from scan stream',
      build: () => ScanBloc(
        bleService: mockBleService,
        logService: mockLogService,
      ),
      setUp: () {
        final controller = StreamController<List<BleDevice>>();
        when(() => mockBleService.scanDevices(filter: any(named: 'filter')))
            .thenAnswer((_) => controller.stream);
        // Emit a device list synchronously so blocTest can capture it
        controller.add([_testDevice('AA:BB')]);
      },
      act: (bloc) => bloc.add(const ScanStarted()),
      expect: () => [
        // First: scanning state emitted
        const ScanState(
          isScanning: true,
          status: ScanStatus.scanning,
        ),
        // Then: device found from stream, added to devices list
        isA<ScanState>()
            .having((s) => s.devices.length, 'has 1 device', 1)
            .having((s) => s.devices.first.id, 'device id', 'AA:BB'),
      ],
    );

    // --- Close ---
    test('should clean up on close', () async {
      final bloc = ScanBloc(
        bleService: mockBleService,
        logService: mockLogService,
      );
      await bloc.close();
      verify(() => mockBleService.stopScan()).called(1);
    });
  });
}
