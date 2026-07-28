import 'package:flutter_test/flutter_test.dart';

import 'package:ble_helper/data/models/ble_service.dart';
import 'package:ble_helper/data/models/ble_characteristic.dart';

void main() {
  group('BleServiceInfo', () {
    const characteristic = BleCharacteristicInfo(
      uuid: '00002A00-0000-1000-8000-00805F9B34FB',
      serviceUuid: '00001800-0000-1000-8000-00805F9B34FB',
      deviceId: 'AA:BB:CC:DD:EE:FF',
      properties: CharacteristicProperties(read: true),
    );

    const service = BleServiceInfo(
      uuid: '00001800-0000-1000-8000-00805F9B34FB',
      deviceId: 'AA:BB:CC:DD:EE:FF',
      isPrimary: true,
      characteristics: [characteristic],
    );

    group('Constructor & Properties', () {
      test('should create BleServiceInfo with all fields', () {
        expect(service.uuid, '00001800-0000-1000-8000-00805F9B34FB');
        expect(service.deviceId, 'AA:BB:CC:DD:EE:FF');
        expect(service.isPrimary, true);
        expect(service.characteristics.length, 1);
      });

      test('should have empty characteristics by default', () {
        const emptyService = BleServiceInfo(
          uuid: '00001801-0000-1000-8000-00805F9B34FB',
          deviceId: 'DEVICE',
          isPrimary: false,
        );
        expect(emptyService.characteristics, isEmpty);
      });
    });

    group('toJson', () {
      test('should serialize to JSON correctly', () {
        final json = service.toJson();
        expect(json['uuid'], service.uuid);
        expect(json['deviceId'], service.deviceId);
        expect(json['isPrimary'], true);
        expect(json['characteristics'], isA<List>());
        expect((json['characteristics'] as List).length, 1);
      });

      test('should serialize empty characteristics', () {
        const emptyService = BleServiceInfo(
          uuid: 'UUID',
          deviceId: 'DEVICE',
          isPrimary: false,
        );
        final json = emptyService.toJson();
        expect(json['characteristics'], isEmpty);
      });
    });

    group('fromJson', () {
      test('should deserialize from JSON correctly', () {
        final json = service.toJson();
        final parsed = BleServiceInfo.fromJson(json);
        expect(parsed.uuid, service.uuid);
        expect(parsed.deviceId, service.deviceId);
        expect(parsed.isPrimary, service.isPrimary);
        expect(parsed.characteristics.length, 1);
        expect(parsed.characteristics.first.uuid, characteristic.uuid);
      });

      test('should handle missing characteristics field', () {
        final json = {
          'uuid': 'SERVICE-UUID',
          'deviceId': 'DEVICE',
          'isPrimary': false,
        };
        final parsed = BleServiceInfo.fromJson(json);
        expect(parsed.characteristics, isEmpty);
      });

      test('should handle null characteristics', () {
        final json = {
          'uuid': 'SERVICE-UUID',
          'deviceId': 'DEVICE',
          'isPrimary': false,
          'characteristics': null,
        };
        final parsed = BleServiceInfo.fromJson(json);
        expect(parsed.characteristics, isEmpty);
      });

      test('should perform roundtrip toJson/fromJson', () {
        final json = service.toJson();
        final restored = BleServiceInfo.fromJson(json);
        expect(restored.uuid, service.uuid);
        expect(restored.deviceId, service.deviceId);
        expect(restored.isPrimary, service.isPrimary);
        expect(restored.characteristics.length, service.characteristics.length);
      });
    });

    group('copyWith', () {
      test('should copy with new values', () {
        final copied = service.copyWith(
          uuid: 'NEW-UUID',
          isPrimary: false,
        );
        expect(copied.uuid, 'NEW-UUID');
        expect(copied.isPrimary, false);
        expect(copied.deviceId, service.deviceId);
        expect(copied.characteristics, service.characteristics);
      });

      test('should copy with no changes', () {
        final copied = service.copyWith();
        expect(copied.uuid, service.uuid);
        expect(copied.deviceId, service.deviceId);
        expect(copied.isPrimary, service.isPrimary);
      });

      test('should replace characteristics', () {
        final newChars = [
          BleCharacteristicInfo(
            uuid: 'CHAR-2',
            serviceUuid: service.uuid,
            deviceId: service.deviceId,
            properties: const CharacteristicProperties(write: true),
          ),
        ];
        final copied = service.copyWith(characteristics: newChars);
        expect(copied.characteristics.length, 1);
        expect(copied.characteristics.first.uuid, 'CHAR-2');
      });
    });
  });
}
