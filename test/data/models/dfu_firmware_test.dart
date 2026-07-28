import 'package:flutter_test/flutter_test.dart';

import 'package:ble_helper/data/models/dfu_firmware.dart';

void main() {
  group('DfuFirmware', () {
    const firmware = DfuFirmware(
      filePath: '/storage/firmware/app_v2.0.zip',
      fileName: 'app_v2.0.zip',
      fileSize: 1024 * 500, // 500 KB
      chipType: DfuChipType.NORDIC,
      firmwareVersion: '2.0.1',
      isValid: true,
    );

    group('Constructor & Properties', () {
      test('should create with all fields', () {
        expect(firmware.filePath, '/storage/firmware/app_v2.0.zip');
        expect(firmware.fileName, 'app_v2.0.zip');
        expect(firmware.fileSize, 512000);
        expect(firmware.chipType, DfuChipType.NORDIC);
        expect(firmware.firmwareVersion, '2.0.1');
        expect(firmware.isValid, true);
      });

      test('should default isValid to true', () {
        const fw = DfuFirmware(
          filePath: '/test.bin',
          fileName: 'test.bin',
          fileSize: 100,
          chipType: DfuChipType.TI,
          firmwareVersion: '1.0',
        );
        expect(fw.isValid, true);
      });
    });

    group('fileSizeFormatted', () {
      test('should format bytes', () {
        const small = DfuFirmware(
          filePath: '/small.bin',
          fileName: 'small.bin',
          fileSize: 500,
          chipType: DfuChipType.CUSTOM,
          firmwareVersion: '1.0',
        );
        expect(small.fileSizeFormatted, '500 B');
      });

      test('should format kilobytes', () {
        const kb = DfuFirmware(
          filePath: '/medium.bin',
          fileName: 'medium.bin',
          fileSize: 500 * 1024,
          chipType: DfuChipType.NORDIC,
          firmwareVersion: '1.0',
        );
        expect(kb.fileSizeFormatted, '500.0 KB');
      });

      test('should format megabytes', () {
        const mb = DfuFirmware(
          filePath: '/large.bin',
          fileName: 'large.bin',
          fileSize: 2 * 1024 * 1024,
          chipType: DfuChipType.DIALOG,
          firmwareVersion: '1.0',
        );
        expect(mb.fileSizeFormatted, '2.0 MB');
      });

      test('should handle 0 bytes', () {
        const empty = DfuFirmware(
          filePath: '/empty.bin',
          fileName: 'empty.bin',
          fileSize: 0,
          chipType: DfuChipType.CUSTOM,
          firmwareVersion: '0',
        );
        expect(empty.fileSizeFormatted, '0 B');
      });
    });

    group('toJson', () {
      test('should serialize to JSON correctly', () {
        final json = firmware.toJson();
        expect(json['filePath'], firmware.filePath);
        expect(json['fileName'], firmware.fileName);
        expect(json['fileSize'], firmware.fileSize);
        expect(json['chipType'], 'NORDIC');
        expect(json['firmwareVersion'], '2.0.1');
        expect(json['isValid'], true);
      });
    });

    group('fromJson', () {
      test('should deserialize from JSON correctly', () {
        final json = firmware.toJson();
        final parsed = DfuFirmware.fromJson(json);
        expect(parsed.filePath, firmware.filePath);
        expect(parsed.fileName, firmware.fileName);
        expect(parsed.fileSize, firmware.fileSize);
        expect(parsed.chipType, firmware.chipType);
        expect(parsed.firmwareVersion, firmware.firmwareVersion);
        expect(parsed.isValid, firmware.isValid);
      });

      test('should handle unknown chipType with orElse', () {
        final json = {
          'filePath': '/test.bin',
          'fileName': 'test.bin',
          'fileSize': 100,
          'chipType': 'UNKNOWN',
          'firmwareVersion': '1.0',
        };
        final parsed = DfuFirmware.fromJson(json);
        expect(parsed.chipType, DfuChipType.CUSTOM);
      });

      test('should handle missing firmwareVersion', () {
        final json = {
          'filePath': '/test.bin',
          'fileName': 'test.bin',
          'fileSize': 100,
          'chipType': 'NORDIC',
        };
        final parsed = DfuFirmware.fromJson(json);
        expect(parsed.firmwareVersion, 'Unknown');
      });

      test('should handle missing isValid', () {
        final json = {
          'filePath': '/test.bin',
          'fileName': 'test.bin',
          'fileSize': 100,
          'chipType': 'NORDIC',
          'firmwareVersion': '1.0',
        };
        final parsed = DfuFirmware.fromJson(json);
        expect(parsed.isValid, true);
      });

      test('should perform roundtrip', () {
        final json = firmware.toJson();
        final restored = DfuFirmware.fromJson(json);
        expect(restored.filePath, firmware.filePath);
        expect(restored.chipType, firmware.chipType);
        expect(restored.fileSizeFormatted, firmware.fileSizeFormatted);
      });
    });

    group('copyWith', () {
      test('should copy with new values', () {
        final copied = firmware.copyWith(
          firmwareVersion: '3.0.0',
          isValid: false,
        );
        expect(copied.firmwareVersion, '3.0.0');
        expect(copied.isValid, false);
        expect(copied.filePath, firmware.filePath);
        expect(copied.chipType, firmware.chipType);
      });
    });
  });

  group('DfuChipType enum', () {
    test('should have four values', () {
      expect(DfuChipType.values.length, 4);
      expect(DfuChipType.values, [
        DfuChipType.NORDIC,
        DfuChipType.TI,
        DfuChipType.DIALOG,
        DfuChipType.CUSTOM,
      ]);
    });
  });
}
