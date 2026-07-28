import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/ble_device.dart';
import '../../../data/models/log_entry.dart';
import '../../../data/repositories/device_repository.dart';
import '../../../services/ble/ble_service_interface.dart';
import '../../../services/log/log_service.dart';
import 'device_event.dart';
import 'device_state.dart';

/// BLoC managing a single device's connection lifecycle and RSSI monitoring.
class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  final String _deviceId;
  final IBleService _bleService;
  final LogService _logService;
  final DeviceRepository _deviceRepo;

  StreamSubscription<ConnectionState>? _connectionSub;
  StreamSubscription<int>? _rssiSub;

  DeviceBloc({
    required String deviceId,
    required IBleService bleService,
    required LogService logService,
    required DeviceRepository deviceRepo,
  })  : _deviceId = deviceId,
        _bleService = bleService,
        _logService = logService,
        _deviceRepo = deviceRepo,
        super(DeviceState(deviceId: deviceId)) {
    on<ConnectRequested>(_onConnectRequested);
    on<DisconnectRequested>(_onDisconnectRequested);
    on<MtuRequested>(_onMtuRequested);
    on<RssiUpdated>(_onRssiUpdated);
    on<ConnectionStateChanged>(_onConnectionStateChanged);
    on<DeviceError>(_onDeviceError);
  }

  Future<void> _onConnectRequested(
    ConnectRequested event,
    Emitter<DeviceState> emit,
  ) async {
    emit(state.copyWith(
      connectionState: ConnectionState.connecting,
      clearError: true,
    ));

    try {
      await _bleService.connect(event.deviceId);

      emit(state.copyWith(connectionState: ConnectionState.connected));

      // Record connection
      await _deviceRepo.recordConnection(
        _buildDevice(),
      );

      await _logService.log(
        LogEntry(
          timestamp: DateTime.now(),
          deviceId: event.deviceId,
          eventType: LogEventType.DEVICE_CONNECTED,
          description: 'Device connected: $event.deviceId',
        ),
      );

      // Start RSSI monitoring
      _startRssiMonitoring(event.deviceId);

      // Start connection state monitoring
      _startConnectionMonitoring(event.deviceId);
    } catch (e) {
      emit(state.copyWith(
        connectionState: ConnectionState.disconnected,
        errorMessage: 'Connection failed: $e',
      ));

      await _logService.log(
        LogEntry(
          timestamp: DateTime.now(),
          deviceId: event.deviceId,
          eventType: LogEventType.ERROR,
          description: 'Connection failed',
          errorDetail: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDisconnectRequested(
    DisconnectRequested event,
    Emitter<DeviceState> emit,
  ) async {
    try {
      await _deviceRepo.recordDisconnection(_deviceId);
      await _bleService.disconnect(_deviceId);

      await _logService.log(
        LogEntry(
          timestamp: DateTime.now(),
          deviceId: _deviceId,
          eventType: LogEventType.DEVICE_DISCONNECTED,
          description: 'Device disconnected: $_deviceId',
        ),
      );

      emit(DeviceState(deviceId: _deviceId));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Disconnect failed: $e'));
    }
  }

  Future<void> _onMtuRequested(
    MtuRequested event,
    Emitter<DeviceState> emit,
  ) async {
    try {
      final int newMtu = await _bleService.requestMtu(_deviceId, event.mtu);
      emit(state.copyWith(mtu: newMtu));

      await _logService.log(
        LogEntry(
          timestamp: DateTime.now(),
          deviceId: _deviceId,
          eventType: LogEventType.MTU_CHANGED,
          description: 'MTU changed to $newMtu',
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'MTU request failed: $e'));
    }
  }

  void _onRssiUpdated(RssiUpdated event, Emitter<DeviceState> emit) {
    emit(state.copyWith(rssi: event.rssi));
  }

  void _onConnectionStateChanged(
    ConnectionStateChanged event,
    Emitter<DeviceState> emit,
  ) {
    emit(state.copyWith(connectionState: event.connectionState));
    if (event.connectionState == ConnectionState.disconnected) {
      _rssiSub?.cancel();
      _connectionSub?.cancel();
    }
  }

  void _onDeviceError(DeviceError event, Emitter<DeviceState> emit) {
    emit(state.copyWith(errorMessage: event.message));
  }

  void _startRssiMonitoring(String deviceId) {
    _rssiSub?.cancel();
    _rssiSub = _bleService.observeRssi(deviceId).listen(
      (int rssi) {
        add(RssiUpdated(rssi: rssi));
      },
      onError: (Object error) {
        add(DeviceError(message: 'RSSI stream error: $error'));
      },
    );
  }

  void _startConnectionMonitoring(String deviceId) {
    _connectionSub?.cancel();
    _connectionSub = _bleService.observeConnection(deviceId).listen(
      (ConnectionState state) {
        add(ConnectionStateChanged(connectionState: state));
      },
    );
  }

  BleDevice _buildDevice() {
    return BleDevice(
      id: _deviceId,
      name: _deviceId,
      macAddress: _deviceId,
      rssi: state.rssi,
      lastSeen: DateTime.now(),
    );
  }

  @override
  Future<void> close() {
    _rssiSub?.cancel();
    _connectionSub?.cancel();
    return super.close();
  }
}
