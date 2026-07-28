import 'dart:async';

import 'ble_service_interface.dart';
import 'ble_gatt_operator.dart';

/// Manages multiple concurrent BLE device connections.
/// Each device gets its own [BleGattOperator] for serialized GATT operations.
class BleDeviceManager {
  final IBleService _bleService;
  final int _maxConcurrentDevices;

  final Map<String, BleGattOperator> _gattOperators = {};

  BleDeviceManager({
    required IBleService bleService,
    int maxConcurrentDevices = 4,
  })  : _bleService = bleService,
        _maxConcurrentDevices = maxConcurrentDevices;

  /// Connect to a BLE device. If the connection pool is full, throws.
  Future<void> connect(String deviceId) async {
    if (_gattOperators.length >= _maxConcurrentDevices &&
        !_gattOperators.containsKey(deviceId)) {
      throw Exception(
        'Max concurrent connections ($_maxConcurrentDevices) reached. '
        'Disconnect a device before connecting a new one.',
      );
    }

    if (_gattOperators.containsKey(deviceId)) {
      return; // Already connected
    }

    await _bleService.connect(deviceId);

    final BleGattOperator operator = BleGattOperator(
      deviceId: deviceId,
      bleService: _bleService,
    );
    _gattOperators[deviceId] = operator;
  }

  /// Disconnect from a BLE device and clean up its operator.
  Future<void> disconnect(String deviceId) async {
    final BleGattOperator? operator = _gattOperators.remove(deviceId);
    if (operator != null) {
      operator.dispose();
    }
    await _bleService.disconnect(deviceId);
  }

  /// Get the GATT operator for a specific device.
  /// Throws if the device is not connected.
  BleGattOperator getOperator(String deviceId) {
    final BleGattOperator? operator = _gattOperators[deviceId];
    if (operator == null) {
      throw Exception('Device not connected: $deviceId');
    }
    return operator;
  }

  /// Get all currently connected device IDs.
  List<String> getConnectedDeviceIds() {
    return _gattOperators.keys.toList();
  }

  /// Check if a device is currently connected.
  bool isConnected(String deviceId) {
    return _gattOperators.containsKey(deviceId);
  }

  /// Number of currently connected devices.
  int get connectedCount => _gattOperators.length;

  /// Maximum allowed concurrent connections.
  int get maxConcurrentDevices => _maxConcurrentDevices;

  /// Check if a new connection can be established.
  bool get canConnect => _gattOperators.length < _maxConcurrentDevices;

  /// Disconnect all devices and clean up.
  Future<void> dispose() async {
    final List<String> deviceIds = _gattOperators.keys.toList();
    for (final String deviceId in deviceIds) {
      await disconnect(deviceId);
    }
    _gattOperators.clear();
  }
}
