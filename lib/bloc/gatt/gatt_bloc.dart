import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/ble_service.dart';
import '../../../data/models/log_entry.dart';
import '../../../core/utils/data_formatter.dart';
import '../../../services/ble/ble_service_interface.dart';
import '../../../services/log/log_service.dart';
import 'gatt_event.dart';
import 'gatt_state.dart';

/// BLoC managing GATT operations: service discovery, read/write/notify.
class GattBloc extends Bloc<GattEvent, GattState> {
  final String _deviceId;
  final IBleService _bleService;
  final LogService _logService;

  final Map<String, StreamSubscription<List<int>>> _notifySubs = {};

  GattBloc({
    required String deviceId,
    required IBleService bleService,
    required LogService logService,
  })  : _deviceId = deviceId,
        _bleService = bleService,
        _logService = logService,
        super(const GattState()) {
    on<DiscoverServices>(_onDiscoverServices);
    on<ReadCharacteristic>(_onReadCharacteristic);
    on<WriteCharacteristic>(_onWriteCharacteristic);
    on<ToggleNotify>(_onToggleNotify);
    on<ReadDescriptor>(_onReadDescriptor);
    on<NotifyValueReceived>(_onNotifyValueReceived);
    on<GattError>(_onGattError);
  }

  Future<void> _onDiscoverServices(
    DiscoverServices event,
    Emitter<GattState> emit,
  ) async {
    emit(state.copyWith(isLoadingServices: true, clearError: true));

    try {
      final List<BleServiceInfo> services =
          await _bleService.discoverServices(_deviceId);
      emit(state.copyWith(
        services: services,
        isLoadingServices: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingServices: false,
        errorMessage: 'Service discovery failed: $e',
      ));

      await _logService.log(
        LogEntry(
          timestamp: DateTime.now(),
          deviceId: _deviceId,
          eventType: LogEventType.ERROR,
          description: 'Service discovery failed',
          errorDetail: e.toString(),
        ),
      );
    }
  }

  Future<void> _onReadCharacteristic(
    ReadCharacteristic event,
    Emitter<GattState> emit,
  ) async {
    final String key = GattState.charKey(event.serviceUuid, event.charUuid);
    final Map<String, CharacteristicState> states =
        Map<String, CharacteristicState>.from(state.characteristicStates);

    states[key] = (states[key] ?? const CharacteristicState())
        .copyWith(isReading: true, clearValue: true);
    emit(state.copyWith(characteristicStates: states));

    try {
      final List<int> value = await _bleService.readCharacteristic(
        _deviceId,
        event.serviceUuid,
        event.charUuid,
      );

      final String hexStr = DataFormatter.toHexString(value, withPrefix: false)
          .replaceAll(' ', '');

      final Map<String, CharacteristicState> updated =
          Map<String, CharacteristicState>.from(state.characteristicStates);
      updated[key] = (updated[key] ?? const CharacteristicState())
          .copyWith(value: value, isReading: false);
      emit(state.copyWith(characteristicStates: updated));

      await _logService.log(
        LogEntry(
          timestamp: DateTime.now(),
          deviceId: _deviceId,
          eventType: LogEventType.GATT_READ,
          direction: LogDirection.RX,
          serviceUuid: event.serviceUuid,
          characteristicUuid: event.charUuid,
          dataHex: hexStr,
          description: 'Read: $hexStr',
        ),
      );
    } catch (e) {
      final Map<String, CharacteristicState> updated =
          Map<String, CharacteristicState>.from(state.characteristicStates);
      updated[key] = (updated[key] ?? const CharacteristicState())
          .copyWith(isReading: false);
      emit(state.copyWith(
        characteristicStates: updated,
        errorMessage: 'Read failed: $e',
      ));
    }
  }

  Future<void> _onWriteCharacteristic(
    WriteCharacteristic event,
    Emitter<GattState> emit,
  ) async {
    final String key = GattState.charKey(event.serviceUuid, event.charUuid);
    final Map<String, CharacteristicState> states =
        Map<String, CharacteristicState>.from(state.characteristicStates);

    states[key] =
        (states[key] ?? const CharacteristicState()).copyWith(isWriting: true);
    emit(state.copyWith(characteristicStates: states));

    try {
      await _bleService.writeCharacteristic(
        _deviceId,
        event.serviceUuid,
        event.charUuid,
        event.data,
        event.withResponse,
      );

      final String hexStr =
          DataFormatter.toHexString(event.data, withPrefix: false)
              .replaceAll(' ', '');

      final Map<String, CharacteristicState> updated =
          Map<String, CharacteristicState>.from(state.characteristicStates);
      updated[key] = (updated[key] ?? const CharacteristicState())
          .copyWith(value: event.data, isWriting: false);
      emit(state.copyWith(characteristicStates: updated));

      await _logService.log(
        LogEntry(
          timestamp: DateTime.now(),
          deviceId: _deviceId,
          eventType: LogEventType.GATT_WRITE,
          direction: LogDirection.TX,
          serviceUuid: event.serviceUuid,
          characteristicUuid: event.charUuid,
          dataHex: hexStr,
          description:
              'Write${event.withResponse ? "" : " (no response)"}: $hexStr',
        ),
      );
    } catch (e) {
      final Map<String, CharacteristicState> updated =
          Map<String, CharacteristicState>.from(state.characteristicStates);
      updated[key] = (updated[key] ?? const CharacteristicState())
          .copyWith(isWriting: false);
      emit(state.copyWith(
        characteristicStates: updated,
        errorMessage: 'Write failed: $e',
      ));
    }
  }

  Future<void> _onToggleNotify(
    ToggleNotify event,
    Emitter<GattState> emit,
  ) async {
    final String key = GattState.charKey(event.serviceUuid, event.charUuid);

    try {
      await _bleService.setNotify(
        _deviceId,
        event.serviceUuid,
        event.charUuid,
        event.enable,
      );

      final Map<String, CharacteristicState> updated =
          Map<String, CharacteristicState>.from(state.characteristicStates);
      updated[key] = (updated[key] ?? const CharacteristicState())
          .copyWith(isNotifying: event.enable);
      emit(state.copyWith(characteristicStates: updated));

      // Set up stream subscription for incoming notifications
      _setupNotifyStream(event.serviceUuid, event.charUuid, event.enable);

      await _logService.log(
        LogEntry(
          timestamp: DateTime.now(),
          deviceId: _deviceId,
          eventType: event.enable
              ? LogEventType.GATT_NOTIFY
              : LogEventType.GATT_INDICATE,
          direction: LogDirection.RX,
          serviceUuid: event.serviceUuid,
          characteristicUuid: event.charUuid,
          description: 'Notify ${event.enable ? "enabled" : "disabled"}',
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Notify toggle failed: $e'));
    }
  }

  Future<void> _onReadDescriptor(
    ReadDescriptor event,
    Emitter<GattState> emit,
  ) async {
    try {
      final List<int> value = await _bleService.readDescriptor(
        _deviceId,
        event.serviceUuid,
        event.charUuid,
        event.descUuid,
      );

      final String hexStr = DataFormatter.toHexString(value, withPrefix: false)
          .replaceAll(' ', '');

      await _logService.log(
        LogEntry(
          timestamp: DateTime.now(),
          deviceId: _deviceId,
          eventType: LogEventType.GATT_READ,
          direction: LogDirection.RX,
          serviceUuid: event.serviceUuid,
          characteristicUuid: event.charUuid,
          dataHex: hexStr,
          description: 'Descriptor read: $hexStr',
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Descriptor read failed: $e'));
    }
  }

  void _onNotifyValueReceived(
    NotifyValueReceived event,
    Emitter<GattState> emit,
  ) {
    final String key = GattState.charKey(event.serviceUuid, event.charUuid);
    final Map<String, CharacteristicState> updated =
        Map<String, CharacteristicState>.from(state.characteristicStates);
    updated[key] = (updated[key] ?? const CharacteristicState())
        .appendNotifyValue(event.value);
    emit(state.copyWith(characteristicStates: updated));

    // Log notify value asynchronously
    final String hexStr =
        DataFormatter.toHexString(event.value, withPrefix: false)
            .replaceAll(' ', '');
    _logService.log(
      LogEntry(
        timestamp: DateTime.now(),
        deviceId: _deviceId,
        eventType: LogEventType.GATT_NOTIFY,
        direction: LogDirection.RX,
        serviceUuid: event.serviceUuid,
        characteristicUuid: event.charUuid,
        dataHex: hexStr,
        description: 'Notification: $hexStr',
      ),
    );
  }

  void _onGattError(GattError event, Emitter<GattState> emit) {
    emit(state.copyWith(errorMessage: event.message));
  }

  void _setupNotifyStream(
    String serviceUuid,
    String charUuid,
    bool enable,
  ) {
    final String key = '$serviceUuid|$charUuid';
    _notifySubs[key]?.cancel();

    if (enable) {
      _notifySubs[key] = _bleService
          .observeNotifyValue(_deviceId, serviceUuid, charUuid)
          .listen(
        (List<int> value) {
          add(NotifyValueReceived(
            serviceUuid: serviceUuid,
            charUuid: charUuid,
            value: value,
          ));
        },
        onError: (Object error) {
          add(GattError(message: 'Notify stream error: $error'));
        },
      );
    }
  }

  @override
  Future<void> close() {
    for (final StreamSubscription<List<int>> sub in _notifySubs.values) {
      sub.cancel();
    }
    _notifySubs.clear();
    return super.close();
  }
}
