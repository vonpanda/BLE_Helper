import 'package:flutter_test/flutter_test.dart';

import 'package:ble_helper/data/models/ble_descriptor.dart';

void main() {
  group('BleDescriptorInfo', () {
    const descriptor = BleDescriptorInfo(
      uuid: '00002902-0000-1000-8000-00805F9B34FB',
      characteristicUuid: '00002A00-0000-1000-8000-00805F9B34FB',
      deviceId: 'AA:BB:CC:DD:EE:FF',
      value: [0x01, 0x00],
    );

    group('Constructor & Properties', () {
      test('should create with all fields', () {
        expect(descriptor.uuid, '00002902-0000-1000-8000-00805F9B34FB');
        expect(descriptor.characteristicUuid,
            '00002A00-0000-1000-8000-00805F9B34FB');
        expect(descriptor.deviceId, 'AA:BB:CC:DD:EE:FF');
        expect(descriptor.value, [0x01, 0x00]);
      });

      test('should allow null value', () {
        const noValue = BleDescriptorInfo(
          uuid: 'DESC',
          characteristicUuid: 'CHAR',
          deviceId: 'DEV',
        );
        expect(noValue.value, isNull);
      });
    });

    group('toJson', () {
      test('should serialize to JSON correctly', () {
        final json = descriptor.toJson();
        expect(json['uuid'], descriptor.uuid);
        expect(json['characteristicUuid'], descriptor.characteristicUuid);
        expect(json['deviceId'], descriptor.deviceId);
        expect(json['value'], [0x01, 0x00]);
      });

      test('should handle null value', () {
        const desc = BleDescriptorInfo(
          uuid: 'DESC',
          characteristicUuid: 'CHAR',
          deviceId: 'DEV',
        );
        final json = desc.toJson();
        expect(json['value'], isNull);
      });
    });

    group('fromJson', () {
      test('should deserialize from JSON correctly', () {
        final json = descriptor.toJson();
        final parsed = BleDescriptorInfo.fromJson(json);
        expect(parsed.uuid, descriptor.uuid);
        expect(parsed.characteristicUuid, descriptor.characteristicUuid);
        expect(parsed.deviceId, descriptor.deviceId);
        expect(parsed.value, [0x01, 0x00]);
      });

      test('should handle missing value', () {
        final json = {
          'uuid': 'DESC',
          'characteristicUuid': 'CHAR',
          'deviceId': 'DEV',
        };
        final parsed = BleDescriptorInfo.fromJson(json);
        expect(parsed.value, isNull);
      });

      test('should handle null value', () {
        final json = {
          'uuid': 'DESC',
          'characteristicUuid': 'CHAR',
          'deviceId': 'DEV',
          'value': null,
        };
        final parsed = BleDescriptorInfo.fromJson(json);
        expect(parsed.value, isNull);
      });

      test('should perform roundtrip', () {
        final json = descriptor.toJson();
        final restored = BleDescriptorInfo.fromJson(json);
        expect(restored.uuid, descriptor.uuid);
        expect(restored.value, descriptor.value);
      });
    });

    group('copyWith', () {
      test('should copy with new values', () {
        final copied = descriptor.copyWith(uuid: 'NEW-DESC', value: [0xFF]);
        expect(copied.uuid, 'NEW-DESC');
        expect(copied.value, [0xFF]);
        expect(copied.characteristicUuid, descriptor.characteristicUuid);
      });

      test('should clear value with clearValue flag', () {
        final copied = descriptor.copyWith(clearValue: true);
        expect(copied.value, isNull);
      });

      test('should copy with no changes', () {
        final copied = descriptor.copyWith();
        expect(copied.uuid, descriptor.uuid);
        expect(copied.value, descriptor.value);
      });
    });
  });
}
