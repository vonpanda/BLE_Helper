import 'package:flutter_test/flutter_test.dart';

import 'package:ble_helper/data/models/advertisement_data.dart';

void main() {
  group('AdvertisementData', () {
    group('Constructor & Defaults', () {
      test('should create with all fields', () {
        const advData = AdvertisementData(
          localName: 'Test Device',
          txPowerLevel: -10,
          isConnectable: true,
          manufacturerId: 0x004C,
          manufacturerData: [0x02, 0x15],
          serviceData: {
            0x180A: [0x01, 0x02]
          },
          serviceUuids: ['0000180A-0000-1000-8000-00805F9B34FB'],
        );
        expect(advData.localName, 'Test Device');
        expect(advData.txPowerLevel, -10);
        expect(advData.isConnectable, true);
        expect(advData.manufacturerId, 0x004C);
        expect(advData.manufacturerData, [0x02, 0x15]);
        expect(advData.serviceData[0x180A], [0x01, 0x02]);
        expect(advData.serviceUuids.length, 1);
      });

      test('should have correct defaults', () {
        const advData = AdvertisementData();
        expect(advData.localName, isNull);
        expect(advData.txPowerLevel, isNull);
        expect(advData.isConnectable, true);
        expect(advData.manufacturerId, isNull);
        expect(advData.manufacturerData, isEmpty);
        expect(advData.serviceData, isEmpty);
        expect(advData.serviceUuids, isEmpty);
        expect(advData.parsedStructures, isEmpty);
      });
    });

    group('parse', () {
      test('should parse AD Flags (0x01)', () {
        const raw = [0x02, 0x01, 0x06]; // length=2, type=0x01, flags=0x06
        final adv = AdvertisementData.parse(raw);
        expect(adv.parsedStructures['Flags'], [0x06]);
      });

      test('should parse Complete Local Name (0x09)', () {
        // BLE AD length includes the type byte, so length=9 for type(1) + "TestName"(8)
        final raw = [
          0x09,
          0x09,
          0x54,
          0x65,
          0x73,
          0x74,
          0x4E,
          0x61,
          0x6D,
          0x65
        ];
        final adv = AdvertisementData.parse(raw);
        expect(adv.localName, 'TestName');
      });

      test('should parse Shortened Local Name (0x08)', () {
        final raw = [0x03, 0x08, 0x41, 0x42]; // "AB"
        final adv = AdvertisementData.parse(raw);
        expect(adv.localName, 'AB');
      });

      test('should parse TX Power Level (0x0A)', () {
        final raw = [0x02, 0x0A, 0xEC]; // -20 dBm in signed byte
        final adv = AdvertisementData.parse(raw);
        expect(adv.txPowerLevel, 0xEC);
      });

      test('should parse 16-bit UUIDs (0x03)', () {
        // Complete 16-bit UUID list: type=0x03, data=0x0A, 0x18 (UUID 180A)
        final raw = [0x03, 0x03, 0x0A, 0x18];
        final adv = AdvertisementData.parse(raw);
        expect(adv.serviceUuids, isNotEmpty);
        expect(adv.serviceUuids.first, contains('180A'));
      });

      test('should parse Manufacturer Specific Data (0xFF)', () {
        final raw = [
          0x05,
          0xFF,
          0x4C,
          0x00,
          0x02,
          0x15
        ]; // Apple iBeacon prefix
        final adv = AdvertisementData.parse(raw);
        expect(adv.parsedStructures['ManufacturerSpecific'],
            [0x4C, 0x00, 0x02, 0x15]);
      });

      test('should handle empty raw data', () {
        final adv = AdvertisementData.parse([]);
        expect(adv.localName, isNull);
        expect(adv.serviceUuids, isEmpty);
        expect(adv.parsedStructures, isEmpty);
      });

      test('should handle invalid length (zero length AD element)', () {
        final raw = [0x00, 0x09, 0x41]; // length=0 should break
        final adv = AdvertisementData.parse(raw);
        expect(adv.localName, isNull);
      });

      test('should handle truncated data', () {
        final raw = [0x10, 0x09]; // length=16 but only 2 bytes available
        final adv = AdvertisementData.parse(raw);
        expect(adv.localName, isNull); // couldn't parse because length exceeds
      });

      test('should track unknown AD types in parsedStructures', () {
        final raw = [0x04, 0xAB, 0x01, 0x02, 0x03]; // Unknown AD type 0xAB
        final adv = AdvertisementData.parse(raw);
        expect(adv.parsedStructures.containsKey('AD_TYPE_0xAB'), true);
        expect(adv.parsedStructures['AD_TYPE_0xAB'], [0x01, 0x02, 0x03]);
      });
    });

    group('toJson / fromJson', () {
      test('should perform roundtrip', () {
        const advData = AdvertisementData(
          localName: 'Test',
          txPowerLevel: -10,
          isConnectable: false,
          manufacturerId: 0x004C,
          manufacturerData: [0x02, 0x15],
          serviceUuids: ['0000180A-0000-1000-8000-00805F9B34FB'],
        );
        final json = advData.toJson();
        final restored = AdvertisementData.fromJson(json);
        expect(restored.localName, 'Test');
        expect(restored.txPowerLevel, -10);
        expect(restored.isConnectable, false);
        expect(restored.manufacturerId, 0x004C);
        expect(restored.manufacturerData, [0x02, 0x15]);
        expect(restored.serviceUuids.length, 1);
      });

      test('should handle null optional fields in JSON', () {
        final json = <String, dynamic>{
          'localName': null,
          'txPowerLevel': null,
          'isConnectable': null,
          'manufacturerId': null,
          'manufacturerData': null,
          'serviceUuids': null,
        };
        final parsed = AdvertisementData.fromJson(json);
        expect(parsed.localName, isNull);
        expect(parsed.isConnectable, true); // default
        expect(parsed.manufacturerData, isEmpty);
        expect(parsed.serviceUuids, isEmpty);
      });
    });

    group('fromFlutterBluePlus', () {
      test('should parse manufacturer data maps without manufacturerId getter',
          () {
        final parsed = AdvertisementData.fromFlutterBluePlus(
          _MockFlutterBlueAdvertisementData(
            advName: 'Sensor Tag',
            txPowerLevel: -8,
            connectable: false,
            manufacturerData: {
              0x004C: [0x02, 0x15]
            },
            serviceData: {
              '180A': [0x01, 0x02]
            },
            serviceUuids: ['180A'],
          ),
        );

        expect(parsed.localName, 'Sensor Tag');
        expect(parsed.txPowerLevel, -8);
        expect(parsed.isConnectable, false);
        expect(parsed.manufacturerId, 0x004C);
        expect(parsed.manufacturerData, [0x02, 0x15]);
        expect(parsed.serviceData[0x180A], [0x01, 0x02]);
        expect(parsed.serviceUuids, ['180A']);
      });

      test('should tolerate missing optional plugin fields', () {
        final parsed = AdvertisementData.fromFlutterBluePlus(
          _MinimalAdvertisementData(),
        );

        expect(parsed.localName, isNull);
        expect(parsed.txPowerLevel, isNull);
        expect(parsed.isConnectable, true);
        expect(parsed.manufacturerId, isNull);
        expect(parsed.manufacturerData, isEmpty);
        expect(parsed.serviceData, isEmpty);
        expect(parsed.serviceUuids, isEmpty);
      });
    });
  });
}

class _MockFlutterBlueAdvertisementData {
  final String? advName;
  final int? txPowerLevel;
  final bool connectable;
  final Map<int, List<int>> manufacturerData;
  final Map<dynamic, List<int>> serviceData;
  final List<dynamic> serviceUuids;

  _MockFlutterBlueAdvertisementData({
    this.advName,
    this.txPowerLevel,
    this.connectable = true,
    this.manufacturerData = const {},
    this.serviceData = const {},
    this.serviceUuids = const [],
  });
}

class _MinimalAdvertisementData {}
