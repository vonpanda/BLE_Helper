import 'package:flutter_test/flutter_test.dart';

import 'package:ble_helper/data/models/ble_device.dart';
import 'package:ble_helper/data/models/advertisement_data.dart';

void main() {
  final testDateTime = DateTime(2025, 1, 15, 10, 30, 0);

  group('BleDevice', () {
    final device = BleDevice(
      id: 'AA:BB:CC:DD:EE:FF',
      name: 'Test Device',
      macAddress: 'AA:BB:CC:DD:EE:FF',
      rssi: -50,
      lastSeen: testDateTime,
      isConnected: false,
      isFavorite: false,
    );

    const advData = AdvertisementData(
      localName: 'AdvDevice',
      txPowerLevel: -10,
      isConnectable: true,
      serviceUuids: ['0000180A-0000-1000-8000-00805F9B34FB'],
    );

    group('Constructor & Properties', () {
      test('should create BleDevice with all fields', () {
        expect(device.id, 'AA:BB:CC:DD:EE:FF');
        expect(device.name, 'Test Device');
        expect(device.macAddress, 'AA:BB:CC:DD:EE:FF');
        expect(device.rssi, -50);
        expect(device.lastSeen, testDateTime);
        expect(device.isConnected, false);
        expect(device.isFavorite, false);
        expect(device.advData, isNull);
      });

      test('should have correct default values', () {
        final defaultDevice = BleDevice(
          id: '00:00',
          name: 'Default',
          macAddress: '00:00',
          rssi: -100,
          lastSeen: testDateTime,
        );
        expect(defaultDevice.isConnected, false);
        expect(defaultDevice.isFavorite, false);
        expect(defaultDevice.advData, isNull);
      });

      test('should store advertisement data', () {
        final deviceWithAdv = BleDevice(
          id: 'FF:EE:DD:CC:BB:AA',
          name: 'Adv Device',
          macAddress: 'FF:EE:DD:CC:BB:AA',
          rssi: -30,
          lastSeen: testDateTime,
          advData: advData,
        );
        expect(deviceWithAdv.advData, isNotNull);
        expect(deviceWithAdv.advData!.localName, 'AdvDevice');
      });
    });

    group('toJson', () {
      test('should serialize to JSON correctly', () {
        final json = device.toJson();
        expect(json['id'], 'AA:BB:CC:DD:EE:FF');
        expect(json['name'], 'Test Device');
        expect(json['macAddress'], 'AA:BB:CC:DD:EE:FF');
        expect(json['rssi'], -50);
        expect(json['isConnected'], false);
        expect(json['isFavorite'], false);
        expect(json['advData'], isNull);
      });

      test('should serialize advData if present', () {
        final deviceWithAdv = device.copyWith(advData: advData);
        final json = deviceWithAdv.toJson();
        expect(json['advData'], isNotNull);
        expect(json['advData']['localName'], 'AdvDevice');
      });

      test('should serialize lastSeen as ISO 8601', () {
        final json = device.toJson();
        expect(json['lastSeen'], testDateTime.toIso8601String());
      });
    });

    group('fromJson', () {
      test('should deserialize from JSON correctly', () {
        final json = {
          'id': '11:22:33:44:55:66',
          'name': 'FromJson Device',
          'macAddress': '11:22:33:44:55:66',
          'rssi': -70,
          'lastSeen': '2025-06-01T12:00:00.000',
          'isConnected': true,
          'isFavorite': true,
          'advData': null,
        };
        final parsed = BleDevice.fromJson(json);
        expect(parsed.id, '11:22:33:44:55:66');
        expect(parsed.name, 'FromJson Device');
        expect(parsed.rssi, -70);
        expect(parsed.isConnected, true);
        expect(parsed.isFavorite, true);
        expect(parsed.advData, isNull);
      });

      test('should handle missing optional booleans', () {
        final json = {
          'id': 'AA:BB',
          'name': 'Minimal',
          'macAddress': 'AA:BB',
          'rssi': -100,
          'lastSeen': '2025-01-01T00:00:00.000',
        };
        final parsed = BleDevice.fromJson(json);
        expect(parsed.isConnected, false);
        expect(parsed.isFavorite, false);
      });

      test('should deserialize advData from JSON', () {
        final json = {
          'id': 'CC:DD',
          'name': 'WithAdv',
          'macAddress': 'CC:DD',
          'rssi': -40,
          'lastSeen': '2025-01-01T00:00:00.000',
          'advData': {
            'localName': 'AdvName',
            'txPowerLevel': -5,
            'isConnectable': false,
            'manufacturerData': [],
            'serviceUuids': [],
          },
        };
        final parsed = BleDevice.fromJson(json);
        expect(parsed.advData, isNotNull);
        expect(parsed.advData!.localName, 'AdvName');
      });

      test('should perform roundtrip toJson/fromJson', () {
        final deviceWithAdv = device.copyWith(
          advData: advData,
          isConnected: true,
          isFavorite: true,
        );
        final json = deviceWithAdv.toJson();
        final restored = BleDevice.fromJson(json);
        expect(restored.id, deviceWithAdv.id);
        expect(restored.name, deviceWithAdv.name);
        expect(restored.rssi, deviceWithAdv.rssi);
        expect(restored.isConnected, deviceWithAdv.isConnected);
        expect(restored.isFavorite, deviceWithAdv.isFavorite);
        expect(restored.advData?.localName, advData.localName);
      });
    });

    group('copyWith', () {
      test('should copy with new values', () {
        final copied = device.copyWith(
          name: 'Updated Device',
          rssi: -60,
          isConnected: true,
        );
        expect(copied.id, device.id);
        expect(copied.name, 'Updated Device');
        expect(copied.rssi, -60);
        expect(copied.isConnected, true);
        expect(copied.macAddress, device.macAddress);
        expect(copied.lastSeen, device.lastSeen);
      });

      test('should copy with no changes', () {
        final copied = device.copyWith();
        expect(copied.id, device.id);
        expect(copied.name, device.name);
        expect(copied.rssi, device.rssi);
        expect(copied.isConnected, device.isConnected);
      });
    });

    group('Equality', () {
      test('should equal device with same id', () {
        final sameId = BleDevice(
          id: 'AA:BB:CC:DD:EE:FF',
          name: 'Different Name',
          macAddress: 'AA:BB:CC:DD:EE:FF',
          rssi: -90,
          lastSeen: DateTime.now(),
        );
        expect(device, sameId);
      });

      test('should not equal device with different id', () {
        final different = BleDevice(
          id: 'different-id',
          name: 'Test Device',
          macAddress: 'AA:BB:CC:DD:EE:FF',
          rssi: -50,
          lastSeen: testDateTime,
        );
        expect(device, isNot(different));
      });

      test('should have consistent hashCode', () {
        final sameId = BleDevice(
          id: 'AA:BB:CC:DD:EE:FF',
          name: 'Different',
          macAddress: 'Different',
          rssi: -90,
          lastSeen: DateTime.now(),
        );
        expect(device.hashCode, sameId.hashCode);
      });
    });

    group('fromScanResult', () {
      test('should create device from mock scan result', () {
        // Create a mock that looks like a flutter_blue_plus ScanResult
        final mockDevice = _MockBleDevice(
          remoteId: 'AA:BB:CC:DD:EE:FF',
          platformName: 'Platform Device',
        );
        final mockAdv = _MockAdvertisementData(
          advName: 'Scan Device',
          connectable: true,
          serviceUuids: [],
        );
        final mockScanResult = _MockScanResult(
          device: mockDevice,
          advertisementData: mockAdv,
          rssi: -45,
        );

        final result = BleDevice.fromScanResult(mockScanResult);
        expect(result.id, 'AA:BB:CC:DD:EE:FF');
        expect(result.name, 'Scan Device'); // advName takes priority
        expect(result.rssi, -45);
        expect(result.isConnected, false);
      });

      test('should fallback to platform name if no advName', () {
        final mockDevice = _MockBleDevice(
          remoteId: '11:22:33:44:55:66',
          platformName: 'Fallback Device',
        );
        final mockAdv = _MockAdvertisementData(
          advName: null,
          connectable: true,
          serviceUuids: [],
        );
        final mockScanResult = _MockScanResult(
          device: mockDevice,
          advertisementData: mockAdv,
          rssi: -80,
        );

        final result = BleDevice.fromScanResult(mockScanResult);
        expect(result.name, 'Fallback Device');
      });

      test('should fallback to Unknown if no name available', () {
        final mockDevice = _MockBleDevice(
          remoteId: 'FF:EE',
          platformName: null,
        );
        final mockAdv = _MockAdvertisementData(
          advName: null,
          connectable: true,
          serviceUuids: [],
        );
        final mockScanResult = _MockScanResult(
          device: mockDevice,
          advertisementData: mockAdv,
          rssi: -100,
        );

        final result = BleDevice.fromScanResult(mockScanResult);
        expect(result.name, 'Unknown');
      });

      test('should handle null rssi', () {
        final mockDevice = _MockBleDevice(
          remoteId: 'AA:BB',
          platformName: 'Test',
        );
        final mockAdv = _MockAdvertisementData(
          advName: 'Test',
          connectable: true,
          serviceUuids: [],
        );
        final mockScanResult = _MockScanResult(
          device: mockDevice,
          advertisementData: mockAdv,
          rssi: null,
        );

        final result = BleDevice.fromScanResult(mockScanResult);
        expect(result.rssi, -100);
      });
    });
  });
}

// --- Minimal mocks for ScanResult-like objects ---
class _MockBleDevice {
  final dynamic remoteId;
  final String? platformName;
  _MockBleDevice({required this.remoteId, this.platformName});
}

class _MockAdvertisementData {
  final String? advName;
  final bool connectable;
  final List<dynamic> serviceUuids;
  final dynamic txPowerLevel = null;
  final dynamic manufacturerId = null;
  final dynamic manufacturerData = null;
  final dynamic serviceData = null;
  _MockAdvertisementData({
    this.advName,
    this.connectable = true,
    this.serviceUuids = const [],
  });
}

class _MockScanResult {
  final dynamic device;
  final dynamic advertisementData;
  final int? rssi;
  _MockScanResult({
    required this.device,
    required this.advertisementData,
    this.rssi,
  });
}
