import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ble_helper/bloc/device/device_bloc.dart';
import 'package:ble_helper/bloc/device/device_event.dart';
import 'package:ble_helper/bloc/device/device_state.dart';
import 'package:ble_helper/data/models/ble_device.dart';
import 'package:ble_helper/data/models/log_entry.dart';
import 'package:ble_helper/data/repositories/device_repository.dart';
import 'package:ble_helper/services/ble/ble_service_interface.dart';
import 'package:ble_helper/services/log/log_service.dart';

// --- Mocks ---

class MockBleService extends Mock implements IBleService {}

class MockLogService extends Mock implements LogService {}

class MockDeviceRepository extends Mock implements DeviceRepository {}

void main() {
  late MockBleService mockBleService;
  late MockLogService mockLogService;
  late MockDeviceRepository mockDeviceRepo;

  const testDeviceId = 'AA:BB:CC:DD:EE:FF';

  setUpAll(() {
    registerFallbackValue(LogEntry(
      timestamp: DateTime.now(),
      deviceId: 'fallback',
      eventType: LogEventType.ERROR,
      description: 'fallback',
    ));
    registerFallbackValue(BleDevice(
      id: 'fallback',
      name: 'fallback',
      macAddress: 'fallback',
      rssi: -100,
      lastSeen: DateTime.now(),
    ));
  });

  setUp(() {
    mockBleService = MockBleService();
    mockLogService = MockLogService();
    mockDeviceRepo = MockDeviceRepository();

    when(() => mockLogService.log(any())).thenAnswer((_) async {});
    when(() => mockBleService.connect(any())).thenAnswer((_) async {});
    when(() => mockBleService.disconnect(any())).thenAnswer((_) async {});
    when(() => mockBleService.requestMtu(any(), any()))
        .thenAnswer((_) async => 185);
    when(() => mockDeviceRepo.recordConnection(any())).thenAnswer((_) async {});
    when(() => mockDeviceRepo.recordDisconnection(any()))
        .thenAnswer((_) async {});

    // Default: RSSI stream emits nothing
    when(() => mockBleService.observeRssi(any()))
        .thenAnswer((_) => const Stream.empty());
    when(() => mockBleService.observeConnection(any()))
        .thenAnswer((_) => const Stream.empty());
  });

  group('DeviceBloc', () {
    // --- Initial State ---
    test('initial state should have the device ID', () {
      final bloc = DeviceBloc(
        deviceId: testDeviceId,
        bleService: mockBleService,
        logService: mockLogService,
        deviceRepo: mockDeviceRepo,
      );
      expect(bloc.state.deviceId, testDeviceId);
      expect(bloc.state.connectionState, ConnectionState.disconnected);
      expect(bloc.state.rssi, -100);
      expect(bloc.state.mtu, 23);
    });

    // --- ConnectRequested ---
    blocTest<DeviceBloc, DeviceState>(
      'should emit connecting then connected on successful connect',
      build: () => DeviceBloc(
        deviceId: testDeviceId,
        bleService: mockBleService,
        logService: mockLogService,
        deviceRepo: mockDeviceRepo,
      ),
      act: (bloc) => bloc.add(const ConnectRequested(deviceId: testDeviceId)),
      expect: () => [
        isA<DeviceState>().having(
            (s) => s.connectionState, 'connecting', ConnectionState.connecting),
        isA<DeviceState>().having(
            (s) => s.connectionState, 'connected', ConnectionState.connected),
      ],
      verify: (_) {
        verify(() => mockBleService.connect(testDeviceId)).called(1);
        verify(() => mockDeviceRepo.recordConnection(any())).called(1);
        verify(() => mockLogService.log(any())).called(1);
      },
    );

    blocTest<DeviceBloc, DeviceState>(
      'should emit error when connect fails',
      build: () => DeviceBloc(
        deviceId: testDeviceId,
        bleService: mockBleService,
        logService: mockLogService,
        deviceRepo: mockDeviceRepo,
      ),
      setUp: () {
        when(() => mockBleService.connect(any()))
            .thenThrow(Exception('Connection timeout'));
      },
      act: (bloc) => bloc.add(const ConnectRequested(deviceId: testDeviceId)),
      expect: () => [
        isA<DeviceState>().having(
            (s) => s.connectionState, 'connecting', ConnectionState.connecting),
        isA<DeviceState>()
            .having((s) => s.connectionState, 'disconnected after error',
                ConnectionState.disconnected)
            .having((s) => s.errorMessage, 'error message',
                contains('Connection failed')),
      ],
    );

    // --- DisconnectRequested ---
    blocTest<DeviceBloc, DeviceState>(
      'should disconnect and emit new state',
      build: () => DeviceBloc(
        deviceId: testDeviceId,
        bleService: mockBleService,
        logService: mockLogService,
        deviceRepo: mockDeviceRepo,
      ),
      seed: () => const DeviceState(
        deviceId: testDeviceId,
        connectionState: ConnectionState.connected,
      ),
      act: (bloc) => bloc.add(const DisconnectRequested()),
      expect: () => [
        isA<DeviceState>().having((s) => s.connectionState, 'disconnected',
            ConnectionState.disconnected),
      ],
    );

    blocTest<DeviceBloc, DeviceState>(
      'should emit error when disconnect fails',
      build: () => DeviceBloc(
        deviceId: testDeviceId,
        bleService: mockBleService,
        logService: mockLogService,
        deviceRepo: mockDeviceRepo,
      ),
      seed: () => const DeviceState(
        deviceId: testDeviceId,
        connectionState: ConnectionState.connected,
      ),
      setUp: () {
        when(() => mockBleService.disconnect(any()))
            .thenThrow(Exception('Disconnect failed'));
      },
      act: (bloc) => bloc.add(const DisconnectRequested()),
      expect: () => [
        isA<DeviceState>().having(
            (s) => s.errorMessage, 'error', contains('Disconnect failed')),
      ],
    );

    // --- MtuRequested ---
    blocTest<DeviceBloc, DeviceState>(
      'should update MTU on successful request',
      build: () => DeviceBloc(
        deviceId: testDeviceId,
        bleService: mockBleService,
        logService: mockLogService,
        deviceRepo: mockDeviceRepo,
      ),
      act: (bloc) => bloc.add(const MtuRequested(mtu: 185)),
      expect: () => [
        isA<DeviceState>().having((s) => s.mtu, 'mtu updated', 185),
      ],
    );

    blocTest<DeviceBloc, DeviceState>(
      'should emit error when MTU request fails',
      build: () => DeviceBloc(
        deviceId: testDeviceId,
        bleService: mockBleService,
        logService: mockLogService,
        deviceRepo: mockDeviceRepo,
      ),
      setUp: () {
        when(() => mockBleService.requestMtu(any(), any()))
            .thenThrow(Exception('MTU negotiation failed'));
      },
      act: (bloc) => bloc.add(const MtuRequested(mtu: 512)),
      expect: () => [
        isA<DeviceState>().having(
            (s) => s.errorMessage, 'error', contains('MTU request failed')),
      ],
    );

    // --- RssiUpdated ---
    blocTest<DeviceBloc, DeviceState>(
      'should update RSSI on RssiUpdated event',
      build: () => DeviceBloc(
        deviceId: testDeviceId,
        bleService: mockBleService,
        logService: mockLogService,
        deviceRepo: mockDeviceRepo,
      ),
      act: (bloc) => bloc.add(const RssiUpdated(rssi: -45)),
      expect: () => [
        isA<DeviceState>().having((s) => s.rssi, 'rssi updated', -45),
      ],
    );

    // --- ConnectionStateChanged ---
    blocTest<DeviceBloc, DeviceState>(
      'should update connection state on ConnectionStateChanged',
      build: () => DeviceBloc(
        deviceId: testDeviceId,
        bleService: mockBleService,
        logService: mockLogService,
        deviceRepo: mockDeviceRepo,
      ),
      act: (bloc) => bloc.add(const ConnectionStateChanged(
        connectionState: ConnectionState.disconnecting,
      )),
      expect: () => [
        isA<DeviceState>().having((s) => s.connectionState, 'disconnecting',
            ConnectionState.disconnecting),
      ],
    );

    // --- DeviceError ---
    blocTest<DeviceBloc, DeviceState>(
      'should set error message on DeviceError event',
      build: () => DeviceBloc(
        deviceId: testDeviceId,
        bleService: mockBleService,
        logService: mockLogService,
        deviceRepo: mockDeviceRepo,
      ),
      act: (bloc) => bloc.add(const DeviceError(message: 'RSSI stream error')),
      expect: () => [
        isA<DeviceState>().having(
            (s) => s.errorMessage, 'error message', 'RSSI stream error'),
      ],
    );

    // --- isConnected getter ---
    test('isConnected should reflect connection state', () {
      expect(
        const DeviceState(connectionState: ConnectionState.connected)
            .isConnected,
        true,
      );
      expect(
        const DeviceState(connectionState: ConnectionState.disconnected)
            .isConnected,
        false,
      );
      expect(
        const DeviceState(connectionState: ConnectionState.connecting)
            .isConnected,
        false,
      );
    });

    // --- Close ---
    test('should clean up subscriptions on close', () async {
      final bloc = DeviceBloc(
        deviceId: testDeviceId,
        bleService: mockBleService,
        logService: mockLogService,
        deviceRepo: mockDeviceRepo,
      );
      await bloc.close();
      // Should not throw
    });
  });
}
