import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ble_helper/bloc/gatt/gatt_bloc.dart';
import 'package:ble_helper/bloc/gatt/gatt_event.dart';
import 'package:ble_helper/bloc/gatt/gatt_state.dart';
import 'package:ble_helper/data/models/ble_service.dart';
import 'package:ble_helper/data/models/log_entry.dart';
import 'package:ble_helper/services/ble/ble_service_interface.dart';
import 'package:ble_helper/services/log/log_service.dart';

// --- Mocks ---

class MockBleService extends Mock implements IBleService {}

class MockLogService extends Mock implements LogService {}

void main() {
  late MockBleService mockBleService;
  late MockLogService mockLogService;

  const testDeviceId = 'AA:BB:CC:DD:EE:FF';
  const testServiceUuid = '00001800-0000-1000-8000-00805F9B34FB';
  const testCharUuid = '00002A00-0000-1000-8000-00805F9B34FB';

  setUpAll(() {
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
  });

  group('GattBloc', () {
    // --- Initial State ---
    test('initial state should be correct', () {
      final bloc = GattBloc(
        deviceId: testDeviceId,
        bleService: mockBleService,
        logService: mockLogService,
      );
      expect(bloc.state, const GattState());
    });

    // --- DiscoverServices ---
    blocTest<GattBloc, GattState>(
      'should discover services successfully',
      build: () => GattBloc(
        deviceId: testDeviceId,
        bleService: mockBleService,
        logService: mockLogService,
      ),
      setUp: () {
        when(() => mockBleService.discoverServices(any())).thenAnswer(
          (_) async => [
            const BleServiceInfo(
              uuid: testServiceUuid,
              deviceId: testDeviceId,
              isPrimary: true,
            ),
          ],
        );
      },
      act: (bloc) => bloc.add(const DiscoverServices()),
      expect: () => [
        isA<GattState>().having((s) => s.isLoadingServices, 'loading', true),
        isA<GattState>()
            .having((s) => s.isLoadingServices, 'loaded', false)
            .having((s) => s.services.length, 'services count', 1)
            .having(
                (s) => s.services.first.uuid, 'service uuid', testServiceUuid),
      ],
    );

    blocTest<GattBloc, GattState>(
      'should emit error when service discovery fails',
      build: () => GattBloc(
        deviceId: testDeviceId,
        bleService: mockBleService,
        logService: mockLogService,
      ),
      setUp: () {
        when(() => mockBleService.discoverServices(any()))
            .thenThrow(Exception('GATT error'));
      },
      act: (bloc) => bloc.add(const DiscoverServices()),
      expect: () => [
        isA<GattState>().having((s) => s.isLoadingServices, 'loading', true),
        isA<GattState>()
            .having((s) => s.isLoadingServices, 'not loading', false)
            .having((s) => s.errorMessage, 'error',
                contains('Service discovery failed')),
      ],
    );

    // --- ReadCharacteristic ---
    blocTest<GattBloc, GattState>(
      'should read characteristic successfully',
      build: () => GattBloc(
        deviceId: testDeviceId,
        bleService: mockBleService,
        logService: mockLogService,
      ),
      setUp: () {
        when(() => mockBleService.readCharacteristic(
              any(),
              any(),
              any(),
            )).thenAnswer((_) async => [0x48, 0x65, 0x6C, 0x6C, 0x6F]);
      },
      act: (bloc) => bloc.add(const ReadCharacteristic(
        serviceUuid: testServiceUuid,
        charUuid: testCharUuid,
      )),
      expect: () => [
        // First: setting isReading = true
        isA<GattState>().having(
          (s) => s.characteristicStates['$testServiceUuid|$testCharUuid']
              ?.isReading,
          'isReading true',
          true,
        ),
        // Then: value set, isReading = false
        isA<GattState>()
            .having(
          (s) => s.characteristicStates['$testServiceUuid|$testCharUuid']
              ?.isReading,
          'isReading false',
          false,
        )
            .having(
          (s) =>
              s.characteristicStates['$testServiceUuid|$testCharUuid']?.value,
          'value',
          [0x48, 0x65, 0x6C, 0x6C, 0x6F],
        ),
      ],
    );

    blocTest<GattBloc, GattState>(
      'should emit error when read fails',
      build: () => GattBloc(
        deviceId: testDeviceId,
        bleService: mockBleService,
        logService: mockLogService,
      ),
      setUp: () {
        when(() => mockBleService.readCharacteristic(any(), any(), any()))
            .thenThrow(Exception('Read timeout'));
      },
      act: (bloc) => bloc.add(const ReadCharacteristic(
        serviceUuid: testServiceUuid,
        charUuid: testCharUuid,
      )),
      expect: () => [
        isA<GattState>(),
        isA<GattState>().having(
          (s) => s.errorMessage,
          'error',
          contains('Read failed'),
        ),
      ],
    );

    // --- WriteCharacteristic ---
    blocTest<GattBloc, GattState>(
      'should write characteristic successfully',
      build: () => GattBloc(
        deviceId: testDeviceId,
        bleService: mockBleService,
        logService: mockLogService,
      ),
      setUp: () {
        when(() => mockBleService.writeCharacteristic(
              any(),
              any(),
              any(),
              any(),
              any(),
            )).thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(const WriteCharacteristic(
        serviceUuid: testServiceUuid,
        charUuid: testCharUuid,
        data: [0x01, 0x02, 0x03],
        withResponse: true,
      )),
      expect: () => [
        isA<GattState>().having(
          (s) => s.characteristicStates['$testServiceUuid|$testCharUuid']
              ?.isWriting,
          'isWriting true',
          true,
        ),
        isA<GattState>()
            .having(
          (s) => s.characteristicStates['$testServiceUuid|$testCharUuid']
              ?.isWriting,
          'isWriting false',
          false,
        )
            .having(
          (s) =>
              s.characteristicStates['$testServiceUuid|$testCharUuid']?.value,
          'value',
          [0x01, 0x02, 0x03],
        ),
      ],
    );

    blocTest<GattBloc, GattState>(
      'should handle write without response',
      build: () => GattBloc(
        deviceId: testDeviceId,
        bleService: mockBleService,
        logService: mockLogService,
      ),
      setUp: () {
        when(() => mockBleService.writeCharacteristic(
              any(),
              any(),
              any(),
              any(),
              any(),
            )).thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(const WriteCharacteristic(
        serviceUuid: testServiceUuid,
        charUuid: testCharUuid,
        data: [0xFF],
        withResponse: false,
      )),
      expect: () => [
        isA<GattState>(),
        isA<GattState>().having(
          (s) => s.characteristicStates['$testServiceUuid|$testCharUuid']
              ?.isWriting,
          'isWriting false',
          false,
        ),
      ],
    );

    // --- ToggleNotify ---
    blocTest<GattBloc, GattState>(
      'should enable notification successfully',
      build: () => GattBloc(
        deviceId: testDeviceId,
        bleService: mockBleService,
        logService: mockLogService,
      ),
      setUp: () {
        when(() => mockBleService.setNotify(any(), any(), any(), any()))
            .thenAnswer((_) async {});
        when(() => mockBleService.observeNotifyValue(
              any(),
              any(),
              any(),
            )).thenAnswer((_) => const Stream.empty());
      },
      act: (bloc) => bloc.add(const ToggleNotify(
        serviceUuid: testServiceUuid,
        charUuid: testCharUuid,
        enable: true,
      )),
      expect: () => [
        isA<GattState>().having(
          (s) => s.characteristicStates['$testServiceUuid|$testCharUuid']
              ?.isNotifying,
          'isNotifying true',
          true,
        ),
      ],
    );

    blocTest<GattBloc, GattState>(
      'should disable notification successfully',
      build: () => GattBloc(
        deviceId: testDeviceId,
        bleService: mockBleService,
        logService: mockLogService,
      ),
      setUp: () {
        when(() => mockBleService.setNotify(any(), any(), any(), any()))
            .thenAnswer((_) async {});
        when(() => mockBleService.observeNotifyValue(
              any(),
              any(),
              any(),
            )).thenAnswer((_) => const Stream.empty());
      },
      seed: () {
        final states = <String, CharacteristicState>{
          '$testServiceUuid|$testCharUuid':
              const CharacteristicState(isNotifying: true),
        };
        return GattState(characteristicStates: states);
      },
      act: (bloc) => bloc.add(const ToggleNotify(
        serviceUuid: testServiceUuid,
        charUuid: testCharUuid,
        enable: false,
      )),
      expect: () => [
        isA<GattState>().having(
          (s) => s.characteristicStates['$testServiceUuid|$testCharUuid']
              ?.isNotifying,
          'isNotifying false',
          false,
        ),
      ],
    );

    // --- ReadDescriptor ---
    blocTest<GattBloc, GattState>(
      'should read descriptor successfully',
      build: () => GattBloc(
        deviceId: testDeviceId,
        bleService: mockBleService,
        logService: mockLogService,
      ),
      setUp: () {
        when(() => mockBleService.readDescriptor(
              any(),
              any(),
              any(),
              any(),
            )).thenAnswer((_) async => [0x01, 0x00]);
      },
      act: (bloc) => bloc.add(const ReadDescriptor(
        serviceUuid: testServiceUuid,
        charUuid: testCharUuid,
        descUuid: '00002902-0000-1000-8000-00805F9B34FB',
      )),
      // ReadDescriptor only logs; it doesn't change state directly
      expect: () => [],
      verify: (_) {
        verify(() => mockLogService.log(any())).called(1);
      },
    );

    // --- NotifyValueReceived ---
    blocTest<GattBloc, GattState>(
      'should append notify value to history',
      build: () => GattBloc(
        deviceId: testDeviceId,
        bleService: mockBleService,
        logService: mockLogService,
      ),
      act: (bloc) => bloc.add(const NotifyValueReceived(
        serviceUuid: testServiceUuid,
        charUuid: testCharUuid,
        value: [0xDE, 0xAD],
      )),
      expect: () => [
        isA<GattState>().having(
          (s) => s.characteristicStates['$testServiceUuid|$testCharUuid']
              ?.notifyHistory.length,
          'history length',
          1,
        ),
      ],
    );

    // --- GattError ---
    blocTest<GattBloc, GattState>(
      'should set error message on GattError event',
      build: () => GattBloc(
        deviceId: testDeviceId,
        bleService: mockBleService,
        logService: mockLogService,
      ),
      act: (bloc) =>
          bloc.add(const GattError(message: 'GATT operation failed')),
      expect: () => [
        isA<GattState>().having(
          (s) => s.errorMessage,
          'error message',
          'GATT operation failed',
        ),
      ],
    );

    // --- Close ---
    test('should clean up notify subscriptions on close', () async {
      final bloc = GattBloc(
        deviceId: testDeviceId,
        bleService: mockBleService,
        logService: mockLogService,
      );
      await bloc.close();
      // Should not throw
    });
  });

  group('CharacteristicState', () {
    test('should create with defaults', () {
      const state = CharacteristicState();
      expect(state.value, isNull);
      expect(state.isReading, false);
      expect(state.isWriting, false);
      expect(state.isNotifying, false);
      expect(state.isIndicating, false);
      expect(state.notifyHistory, isEmpty);
    });

    test('should append to notify history and keep max 50', () {
      var state = const CharacteristicState();
      // Add 55 entries to test cap
      for (int i = 0; i < 55; i++) {
        state = state.appendNotifyValue([i]);
      }
      expect(state.notifyHistory.length, 50);
      expect(state.notifyHistory.first, [5]); // 0-4 were removed
      expect(state.notifyHistory.last, [54]);
    });

    test('should update value on notify append', () {
      var state = const CharacteristicState();
      state = state.appendNotifyValue([0xAA, 0xBB]);
      expect(state.value, [0xAA, 0xBB]);
    });
  });

  group('GattState.charKey', () {
    test('should generate correct key format', () {
      expect(
        GattState.charKey('SVC-UUID', 'CHAR-UUID'),
        'SVC-UUID|CHAR-UUID',
      );
    });
  });
}
