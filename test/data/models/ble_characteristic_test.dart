import 'package:flutter_test/flutter_test.dart';

import 'package:ble_helper/data/models/ble_characteristic.dart';

void main() {
  group('CharacteristicProperties', () {
    group('Constructor & Properties', () {
      test('should have all properties false by default', () {
        const props = CharacteristicProperties();
        expect(props.read, false);
        expect(props.write, false);
        expect(props.writeWithoutResponse, false);
        expect(props.notify, false);
        expect(props.indicate, false);
      });

      test('should create with specific properties', () {
        const props = CharacteristicProperties(
          read: true,
          write: true,
          notify: true,
        );
        expect(props.read, true);
        expect(props.write, true);
        expect(props.notify, true);
        expect(props.writeWithoutResponse, false);
        expect(props.indicate, false);
      });
    });

    group('fromFlags', () {
      test('should parse flag strings correctly', () {
        final props = CharacteristicProperties.fromFlags([
          'read',
          'write',
          'notify',
        ]);
        expect(props.read, true);
        expect(props.write, true);
        expect(props.notify, true);
        expect(props.writeWithoutResponse, false);
        expect(props.indicate, false);
      });

      test('should handle empty flags list', () {
        final props = CharacteristicProperties.fromFlags([]);
        expect(props.read, false);
        expect(props.write, false);
        expect(props.writeWithoutResponse, false);
        expect(props.notify, false);
        expect(props.indicate, false);
      });

      test('should handle all flags', () {
        final props = CharacteristicProperties.fromFlags([
          'read',
          'write',
          'writeWithoutResponse',
          'notify',
          'indicate',
        ]);
        expect(props.read, true);
        expect(props.write, true);
        expect(props.writeWithoutResponse, true);
        expect(props.notify, true);
        expect(props.indicate, true);
      });
    });

    group('canWrite', () {
      test('should be true when write is true', () {
        const props = CharacteristicProperties(write: true);
        expect(props.canWrite, true);
      });

      test('should be true when writeWithoutResponse is true', () {
        const props = CharacteristicProperties(writeWithoutResponse: true);
        expect(props.canWrite, true);
      });

      test('should be false when neither write property is set', () {
        const props = CharacteristicProperties(read: true, notify: true);
        expect(props.canWrite, false);
      });
    });

    group('labels', () {
      test('should return labels for set properties', () {
        const props = CharacteristicProperties(read: true, write: true);
        expect(props.labels, contains('READ'));
        expect(props.labels, contains('WRITE'));
        expect(props.labels.length, 2);
      });

      test('should return empty list for no properties', () {
        const props = CharacteristicProperties();
        expect(props.labels, isEmpty);
      });

      test('should return all labels when all set', () {
        const props = CharacteristicProperties(
          read: true,
          write: true,
          writeWithoutResponse: true,
          notify: true,
          indicate: true,
        );
        expect(props.labels.length, 5);
        expect(props.labels,
            ['READ', 'WRITE', 'WRITE_NO_RESP', 'NOTIFY', 'INDICATE']);
      });
    });

    group('toJson / fromJson', () {
      test('should roundtrip correctly', () {
        const props = CharacteristicProperties(
          read: true,
          write: true,
          notify: true,
        );
        final json = props.toJson();
        expect(json['read'], true);
        expect(json['write'], true);
        expect(json['notify'], true);
        expect(json['writeWithoutResponse'], false);

        final restored = CharacteristicProperties.fromJson(json);
        expect(restored.read, props.read);
        expect(restored.write, props.write);
        expect(restored.notify, props.notify);
        expect(restored.writeWithoutResponse, props.writeWithoutResponse);
      });

      test('should handle empty json with defaults', () {
        final restored = CharacteristicProperties.fromJson({});
        expect(restored.read, false);
        expect(restored.write, false);
      });
    });
  });

  group('BleCharacteristicInfo', () {
    const props =
        CharacteristicProperties(read: true, write: true, notify: true);

    const characteristic = BleCharacteristicInfo(
      uuid: '00002A00-0000-1000-8000-00805F9B34FB',
      serviceUuid: '00001800-0000-1000-8000-00805F9B34FB',
      deviceId: 'AA:BB:CC:DD:EE:FF',
      properties: props,
      lastReadValue: [0x48, 0x65, 0x6C, 0x6C, 0x6F], // "Hello"
    );

    group('Constructor & Properties', () {
      test('should create with all fields', () {
        expect(characteristic.uuid, '00002A00-0000-1000-8000-00805F9B34FB');
        expect(
            characteristic.serviceUuid, '00001800-0000-1000-8000-00805F9B34FB');
        expect(characteristic.deviceId, 'AA:BB:CC:DD:EE:FF');
        expect(characteristic.properties, props);
        expect(characteristic.lastReadValue, [0x48, 0x65, 0x6C, 0x6C, 0x6F]);
        expect(characteristic.isNotifying, false);
        expect(characteristic.isIndicating, false);
        expect(characteristic.descriptors, isEmpty);
      });

      test('should have correct defaults', () {
        const simple = BleCharacteristicInfo(
          uuid: 'CHAR',
          serviceUuid: 'SVC',
          deviceId: 'DEV',
          properties: CharacteristicProperties(),
        );
        expect(simple.lastReadValue, isNull);
        expect(simple.lastNotifyValue, isNull);
        expect(simple.isNotifying, false);
        expect(simple.isIndicating, false);
        expect(simple.descriptors, isEmpty);
      });
    });

    group('toJson', () {
      test('should serialize to JSON correctly', () {
        final json = characteristic.toJson();
        expect(json['uuid'], characteristic.uuid);
        expect(json['serviceUuid'], characteristic.serviceUuid);
        expect(json['deviceId'], characteristic.deviceId);
        expect(json['properties'], isA<Map>());
        expect(json['lastReadValue'], [0x48, 0x65, 0x6C, 0x6C, 0x6F]);
        expect(json['isNotifying'], false);
        expect(json['descriptors'], isEmpty);
      });
    });

    group('fromJson', () {
      test('should deserialize from JSON correctly', () {
        final json = characteristic.toJson();
        final parsed = BleCharacteristicInfo.fromJson(json);
        expect(parsed.uuid, characteristic.uuid);
        expect(parsed.properties.read, true);
        expect(parsed.lastReadValue, [0x48, 0x65, 0x6C, 0x6C, 0x6F]);
      });

      test('should handle missing optional fields', () {
        final json = {
          'uuid': 'CHAR',
          'serviceUuid': 'SVC',
          'deviceId': 'DEV',
          'properties': const CharacteristicProperties().toJson(),
        };
        final parsed = BleCharacteristicInfo.fromJson(json);
        expect(parsed.lastReadValue, isNull);
        expect(parsed.lastNotifyValue, isNull);
        expect(parsed.isNotifying, false);
        expect(parsed.descriptors, isEmpty);
      });

      test('should perform roundtrip', () {
        final json = characteristic.toJson();
        final restored = BleCharacteristicInfo.fromJson(json);
        expect(restored.uuid, characteristic.uuid);
        expect(restored.lastReadValue, characteristic.lastReadValue);
        expect(restored.properties.read, characteristic.properties.read);
      });
    });

    group('copyWith', () {
      test('should copy with new values', () {
        final copied = characteristic.copyWith(
          uuid: 'NEW-CHAR',
          isNotifying: true,
        );
        expect(copied.uuid, 'NEW-CHAR');
        expect(copied.isNotifying, true);
        expect(copied.serviceUuid, characteristic.serviceUuid);
        expect(copied.lastReadValue, characteristic.lastReadValue);
      });

      test('should clear read value with clearReadValue flag', () {
        final copied = characteristic.copyWith(clearReadValue: true);
        expect(copied.lastReadValue, isNull);
        expect(copied.uuid, characteristic.uuid);
      });

      test('should clear notify value with clearNotifyValue flag', () {
        final withNotify = characteristic.copyWith(
          lastNotifyValue: [0x01, 0x02],
        );
        expect(withNotify.lastNotifyValue, [0x01, 0x02]);
        final cleared = withNotify.copyWith(clearNotifyValue: true);
        expect(cleared.lastNotifyValue, isNull);
      });
    });
  });
}
