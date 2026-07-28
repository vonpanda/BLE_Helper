import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

import 'ble_service_interface.dart';
import '../../data/models/ble_device.dart';
import '../../data/models/ble_service.dart' as model;
import '../../data/models/ble_characteristic.dart' as model;
import '../../data/models/ble_descriptor.dart';
import '../../data/models/scan_filter.dart' as sf;
import '../../core/utils/ble_utils.dart';

/// Concrete implementation of [IBleService] using flutter_blue_plus.
class BleService implements IBleService {
  final Map<String, fbp.BluetoothDevice> _connectedDevices = {};
  final Map<String, List<StreamSubscription<dynamic>>> _subscriptions = {};

  BleService();

  @override
  Stream<List<BleDevice>> scanDevices({sf.ScanFilter? filter}) async* {
    try {
      final Map<String, fbp.ScanResult> latestResults = {};

      await fbp.FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 30),
        androidUsesFineLocation: true,
      );

      await for (final List<fbp.ScanResult> results
          in fbp.FlutterBluePlus.scanResults) {
        for (final fbp.ScanResult result in results) {
          if (!_matchesFilter(result, filter)) {
            continue;
          }
          latestResults[result.device.remoteId.str] = result;
        }

        final List<BleDevice> devices =
            latestResults.values.map((fbp.ScanResult result) {
          return BleDevice.fromScanResult(result, isFavorite: false);
        }).toList();

        yield _sortDevices(devices, filter);
      }
    } catch (e) {
      throw Exception('BLE scan error: $e');
    }
  }

  @override
  Future<void> stopScan() async {
    try {
      await fbp.FlutterBluePlus.stopScan();
    } catch (_) {}
  }

  @override
  Future<void> connect(String deviceId) async {
    try {
      final fbp.BluetoothDevice device = fbp.BluetoothDevice.fromId(deviceId);
      _connectedDevices[deviceId] = device;
      await device.connect(timeout: const Duration(seconds: 10));
    } catch (e) {
      _connectedDevices.remove(deviceId);
      rethrow;
    }
  }

  @override
  Future<void> disconnect(String deviceId) async {
    try {
      final fbp.BluetoothDevice? device = _connectedDevices[deviceId];
      if (device != null) {
        await device.disconnect();
      }
    } catch (_) {
    } finally {
      _cancelSubscriptions(deviceId);
      _connectedDevices.remove(deviceId);
    }
  }

  @override
  Future<List<model.BleServiceInfo>> discoverServices(String deviceId) async {
    try {
      final fbp.BluetoothDevice? device = _connectedDevices[deviceId];
      if (device == null) throw Exception('Device not connected: $deviceId');

      final List<fbp.BluetoothService> services =
          await device.discoverServices();

      return services.map((fbp.BluetoothService service) {
        return model.BleServiceInfo(
          uuid: BleUtils.normalizeUuid(service.serviceUuid.toString()),
          deviceId: deviceId,
          isPrimary: service.isPrimary,
          characteristics:
              service.characteristics.map((fbp.BluetoothCharacteristic c) {
            return model.BleCharacteristicInfo(
              uuid: BleUtils.normalizeUuid(c.characteristicUuid.toString()),
              serviceUuid:
                  BleUtils.normalizeUuid(service.serviceUuid.toString()),
              deviceId: deviceId,
              properties: _mapProperties(c.properties),
              descriptors: c.descriptors.map((fbp.BluetoothDescriptor d) {
                return BleDescriptorInfo(
                  uuid: BleUtils.normalizeUuid(d.descriptorUuid.toString()),
                  characteristicUuid:
                      BleUtils.normalizeUuid(c.characteristicUuid.toString()),
                  deviceId: deviceId,
                );
              }).toList(),
            );
          }).toList(),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to discover services: $e');
    }
  }

  @override
  Future<List<int>> readCharacteristic(
    String deviceId,
    String serviceUuid,
    String charUuid,
  ) async {
    try {
      final fbp.BluetoothDevice? device = _connectedDevices[deviceId];
      if (device == null) throw Exception('Device not connected: $deviceId');

      final List<fbp.BluetoothService> services =
          await device.discoverServices();
      for (final fbp.BluetoothService service in services) {
        if (service.serviceUuid.toString().toUpperCase() ==
            BleUtils.normalizeUuid(serviceUuid).toUpperCase()) {
          for (final fbp.BluetoothCharacteristic c in service.characteristics) {
            if (c.characteristicUuid.toString().toUpperCase() ==
                BleUtils.normalizeUuid(charUuid).toUpperCase()) {
              final List<int> value = await c.read();
              return value;
            }
          }
        }
      }
      throw Exception('Characteristic not found: $charUuid');
    } catch (e) {
      throw Exception('Failed to read characteristic: $e');
    }
  }

  @override
  Future<void> writeCharacteristic(
    String deviceId,
    String serviceUuid,
    String charUuid,
    List<int> data,
    bool withResponse,
  ) async {
    try {
      final fbp.BluetoothDevice? device = _connectedDevices[deviceId];
      if (device == null) throw Exception('Device not connected: $deviceId');

      final List<fbp.BluetoothService> services =
          await device.discoverServices();
      for (final fbp.BluetoothService service in services) {
        if (service.serviceUuid.toString().toUpperCase() ==
            BleUtils.normalizeUuid(serviceUuid).toUpperCase()) {
          for (final fbp.BluetoothCharacteristic c in service.characteristics) {
            if (c.characteristicUuid.toString().toUpperCase() ==
                BleUtils.normalizeUuid(charUuid).toUpperCase()) {
              await c.write(data, withoutResponse: !withResponse);
              return;
            }
          }
        }
      }
      throw Exception('Characteristic not found: $charUuid');
    } catch (e) {
      throw Exception('Failed to write characteristic: $e');
    }
  }

  @override
  Future<void> setNotify(
    String deviceId,
    String serviceUuid,
    String charUuid,
    bool enable,
  ) async {
    try {
      final fbp.BluetoothDevice? device = _connectedDevices[deviceId];
      if (device == null) throw Exception('Device not connected: $deviceId');

      final List<fbp.BluetoothService> services =
          await device.discoverServices();
      for (final fbp.BluetoothService service in services) {
        if (service.serviceUuid.toString().toUpperCase() ==
            BleUtils.normalizeUuid(serviceUuid).toUpperCase()) {
          for (final fbp.BluetoothCharacteristic c in service.characteristics) {
            if (c.characteristicUuid.toString().toUpperCase() ==
                BleUtils.normalizeUuid(charUuid).toUpperCase()) {
              await c.setNotifyValue(enable);
              return;
            }
          }
        }
      }
      throw Exception('Characteristic not found: $charUuid');
    } catch (e) {
      throw Exception('Failed to set notify: $e');
    }
  }

  @override
  Future<int> requestMtu(String deviceId, int mtu) async {
    try {
      final fbp.BluetoothDevice? device = _connectedDevices[deviceId];
      if (device == null) throw Exception('Device not connected: $deviceId');
      return await device.requestMtu(mtu);
    } catch (e) {
      throw Exception('Failed to request MTU: $e');
    }
  }

  @override
  Stream<int> observeRssi(String deviceId) {
    return (() async* {
      final fbp.BluetoothDevice? device = _connectedDevices[deviceId];
      if (device == null) {
        throw Exception('Device not connected: $deviceId');
      }

      while (_connectedDevices.containsKey(deviceId)) {
        yield await device.readRssi();
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    })();
  }

  @override
  Stream<ConnectionState> observeConnection(String deviceId) {
    try {
      final fbp.BluetoothDevice? device = _connectedDevices[deviceId];
      if (device == null) {
        return Stream.value(ConnectionState.disconnected);
      }
      return device.connectionState
          .map((fbp.BluetoothConnectionState fbpState) {
        switch (fbpState) {
          case fbp.BluetoothConnectionState.disconnected:
            return ConnectionState.disconnected;
          case fbp.BluetoothConnectionState.connected:
            return ConnectionState.connected;
          default:
            return ConnectionState.disconnected;
        }
      });
    } catch (e) {
      return Stream.value(ConnectionState.disconnected);
    }
  }

  @override
  Future<List<int>> readDescriptor(
    String deviceId,
    String serviceUuid,
    String charUuid,
    String descUuid,
  ) async {
    try {
      final fbp.BluetoothDevice? device = _connectedDevices[deviceId];
      if (device == null) throw Exception('Device not connected: $deviceId');

      final List<fbp.BluetoothService> services =
          await device.discoverServices();
      for (final fbp.BluetoothService service in services) {
        if (service.serviceUuid.toString().toUpperCase() ==
            BleUtils.normalizeUuid(serviceUuid).toUpperCase()) {
          for (final fbp.BluetoothCharacteristic c in service.characteristics) {
            if (c.characteristicUuid.toString().toUpperCase() ==
                BleUtils.normalizeUuid(charUuid).toUpperCase()) {
              for (final fbp.BluetoothDescriptor d in c.descriptors) {
                if (d.descriptorUuid.toString().toUpperCase() ==
                    BleUtils.normalizeUuid(descUuid).toUpperCase()) {
                  final List<int> value = await d.read();
                  return value;
                }
              }
            }
          }
        }
      }
      throw Exception('Descriptor not found: $descUuid');
    } catch (e) {
      throw Exception('Failed to read descriptor: $e');
    }
  }

  @override
  Future<void> writeDescriptor(
    String deviceId,
    String serviceUuid,
    String charUuid,
    String descUuid,
    List<int> data,
  ) async {
    try {
      final fbp.BluetoothDevice? device = _connectedDevices[deviceId];
      if (device == null) throw Exception('Device not connected: $deviceId');

      final List<fbp.BluetoothService> services =
          await device.discoverServices();
      for (final fbp.BluetoothService service in services) {
        if (service.serviceUuid.toString().toUpperCase() ==
            BleUtils.normalizeUuid(serviceUuid).toUpperCase()) {
          for (final fbp.BluetoothCharacteristic c in service.characteristics) {
            if (c.characteristicUuid.toString().toUpperCase() ==
                BleUtils.normalizeUuid(charUuid).toUpperCase()) {
              for (final fbp.BluetoothDescriptor d in c.descriptors) {
                if (d.descriptorUuid.toString().toUpperCase() ==
                    BleUtils.normalizeUuid(descUuid).toUpperCase()) {
                  await d.write(data);
                  return;
                }
              }
            }
          }
        }
      }
      throw Exception('Descriptor not found: $descUuid');
    } catch (e) {
      throw Exception('Failed to write descriptor: $e');
    }
  }

  @override
  Stream<List<int>> observeNotifyValue(
    String deviceId,
    String serviceUuid,
    String charUuid,
  ) {
    try {
      final fbp.BluetoothDevice? device = _connectedDevices[deviceId];
      if (device == null) {
        return Stream.error(Exception('Device not connected: $deviceId'));
      }

      final StreamController<List<int>> controller =
          StreamController<List<int>>.broadcast();

      device
          .discoverServices()
          .then((List<fbp.BluetoothService> services) async {
        for (final fbp.BluetoothService service in services) {
          if (service.serviceUuid.toString().toUpperCase() ==
              BleUtils.normalizeUuid(serviceUuid).toUpperCase()) {
            for (final fbp.BluetoothCharacteristic c
                in service.characteristics) {
              if (c.characteristicUuid.toString().toUpperCase() ==
                  BleUtils.normalizeUuid(charUuid).toUpperCase()) {
                final StreamSubscription<List<int>> sub =
                    c.onValueReceived.listen((List<int> value) {
                  controller.add(value);
                });

                _addSubscription(deviceId, sub);
              }
            }
          }
        }
      }).catchError((Object error) {
        controller.addError(error);
      });

      return controller.stream;
    } catch (e) {
      return Stream.error(Exception('Failed to observe notify: $e'));
    }
  }

  @override
  bool isConnected(String deviceId) {
    return _connectedDevices.containsKey(deviceId);
  }

  @override
  List<String> getConnectedDeviceIds() {
    return _connectedDevices.keys.toList();
  }

  @override
  Future<void> dispose() async {
    for (final String deviceId in _connectedDevices.keys.toList()) {
      await disconnect(deviceId);
    }
    _connectedDevices.clear();
  }

  // --- Private helpers ---

  bool _matchesFilter(fbp.ScanResult result, sf.ScanFilter? filter) {
    if (filter == null) {
      return true;
    }

    if (filter.nameFilter != null && filter.nameFilter!.isNotEmpty) {
      final String name = result.advertisementData.advName.isNotEmpty
          ? result.advertisementData.advName
          : result.device.platformName;
      if (!name.toLowerCase().contains(filter.nameFilter!.toLowerCase())) {
        return false;
      }
    }

    if (filter.macFilter != null && filter.macFilter!.isNotEmpty) {
      final String remoteId = result.device.remoteId.str.toLowerCase();
      if (!remoteId.contains(filter.macFilter!.toLowerCase())) {
        return false;
      }
    }

    if (filter.rssiMin != null && result.rssi < filter.rssiMin!) {
      return false;
    }

    return true;
  }

  List<BleDevice> _sortDevices(
    List<BleDevice> devices,
    sf.ScanFilter? filter,
  ) {
    final List<BleDevice> sorted = List<BleDevice>.from(devices);

    switch (filter?.sortBy ?? sf.SortBy.RSSI) {
      case sf.SortBy.RSSI:
        sorted.sort((a, b) => b.rssi.compareTo(a.rssi));
        break;
      case sf.SortBy.NAME:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case sf.SortBy.LAST_SEEN:
        sorted.sort((a, b) => b.lastSeen.compareTo(a.lastSeen));
        break;
    }

    if (filter?.sortOrder == sf.SortOrder.ASC) {
      return sorted.reversed.toList();
    }
    return sorted;
  }

  model.CharacteristicProperties _mapProperties(
    fbp.CharacteristicProperties properties,
  ) {
    return model.CharacteristicProperties(
      read: properties.read,
      write: properties.write,
      writeWithoutResponse: properties.writeWithoutResponse,
      notify: properties.notify,
      indicate: properties.indicate,
    );
  }

  void _addSubscription(String deviceId, StreamSubscription<dynamic> sub) {
    _subscriptions.putIfAbsent(deviceId, () => []).add(sub);
  }

  void _cancelSubscriptions(String deviceId) {
    final List<StreamSubscription<dynamic>>? subs =
        _subscriptions.remove(deviceId);
    if (subs != null) {
      for (final StreamSubscription<dynamic> sub in subs) {
        sub.cancel();
      }
    }
  }
}
