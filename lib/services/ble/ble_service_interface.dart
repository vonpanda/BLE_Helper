import 'dart:async';

import '../../data/models/ble_device.dart';
import '../../data/models/ble_service.dart';
import '../../data/models/scan_filter.dart' as sf;

/// Connection state enum for BLE device connections.
enum ConnectionState {
  disconnected,
  connecting,
  connected,
  disconnecting,
}

/// Abstract interface for all BLE operations.
/// Implementations use flutter_blue_plus to interact with the platform BLE stack.
abstract class IBleService {
  /// Start scanning for nearby BLE devices.
  /// Returns a stream of device lists that updates as devices are discovered.
  Stream<List<BleDevice>> scanDevices({sf.ScanFilter? filter});

  /// Stop the active BLE scan.
  Future<void> stopScan();

  /// Connect to a BLE device by its ID.
  Future<void> connect(String deviceId);

  /// Disconnect from a BLE device by its ID.
  Future<void> disconnect(String deviceId);

  /// Discover GATT services on the connected device.
  Future<List<BleServiceInfo>> discoverServices(String deviceId);

  /// Read the value of a characteristic.
  Future<List<int>> readCharacteristic(
    String deviceId,
    String serviceUuid,
    String charUuid,
  );

  /// Write data to a characteristic.
  Future<void> writeCharacteristic(
    String deviceId,
    String serviceUuid,
    String charUuid,
    List<int> data,
    bool withResponse,
  );

  /// Enable or disable notifications/indications on a characteristic.
  Future<void> setNotify(
    String deviceId,
    String serviceUuid,
    String charUuid,
    bool enable,
  );

  /// Request an MTU change on a connection.
  Future<int> requestMtu(String deviceId, int mtu);

  /// Observe RSSI updates for a connected device.
  Stream<int> observeRssi(String deviceId);

  /// Observe the connection state of a device.
  Stream<ConnectionState> observeConnection(String deviceId);

  /// Read the value of a descriptor.
  Future<List<int>> readDescriptor(
    String deviceId,
    String serviceUuid,
    String charUuid,
    String descUuid,
  );

  /// Write data to a descriptor.
  Future<void> writeDescriptor(
    String deviceId,
    String serviceUuid,
    String charUuid,
    String descUuid,
    List<int> data,
  );

  /// Observe notification/indication values from a characteristic.
  Stream<List<int>> observeNotifyValue(
    String deviceId,
    String serviceUuid,
    String charUuid,
  );

  /// Check if a device is currently connected.
  bool isConnected(String deviceId);

  /// Get all currently connected device IDs.
  List<String> getConnectedDeviceIds();

  /// Dispose of all resources.
  Future<void> dispose();
}
