import 'package:flutter_test/flutter_test.dart';

import 'package:ble_helper/core/utils/data_formatter.dart';

void main() {
  group('DataFormatter', () {
    group('toHexString', () {
      test('should format bytes as uppercase hex', () {
        final bytes = [0x1A, 0x2B, 0xFF, 0x00];
        expect(DataFormatter.toHexString(bytes), '1A 2B FF 00');
      });

      test('should format single byte', () {
        expect(DataFormatter.toHexString([0x0A]), '0A');
        expect(DataFormatter.toHexString([0xFF]), 'FF');
      });

      test('should handle empty list', () {
        expect(DataFormatter.toHexString([]), '');
      });

      test('should include 0x prefix when withPrefix is true', () {
        final bytes = [0x1A, 0x2B];
        expect(DataFormatter.toHexString(bytes, withPrefix: true), '0x1A 0x2B');
      });

      test('should pad single-digit hex values', () {
        expect(DataFormatter.toHexString([0x01, 0x0F, 0xA0]), '01 0F A0');
      });

      test('should handle all zeros', () {
        expect(DataFormatter.toHexString([0x00, 0x00, 0x00]), '00 00 00');
      });
    });

    group('toAsciiString', () {
      test('should convert printable bytes to ASCII', () {
        final bytes = [0x48, 0x65, 0x6C, 0x6C, 0x6F]; // "Hello"
        expect(DataFormatter.toAsciiString(bytes), 'Hello');
      });

      test('should replace non-printable bytes with dot', () {
        final bytes = [0x48, 0x00, 0x65, 0xFF, 0x6C];
        expect(DataFormatter.toAsciiString(bytes), 'H.e.l');
      });

      test('should handle empty list', () {
        expect(DataFormatter.toAsciiString([]), '');
      });

      test('should handle edge printable characters', () {
        // 32 = space, 126 = ~
        final bytes = [32, 65, 126];
        expect(DataFormatter.toAsciiString(bytes), ' A~');
      });

      test('should replace bytes below 32 with dot', () {
        final bytes = [31, 65];
        expect(DataFormatter.toAsciiString(bytes), '.A');
      });

      test('should replace bytes above 126 with dot', () {
        final bytes = [65, 127];
        expect(DataFormatter.toAsciiString(bytes), 'A.');
      });
    });

    group('toDecString', () {
      test('should format bytes as decimal', () {
        final bytes = [10, 255, 0, 128];
        expect(DataFormatter.toDecString(bytes), '10 255 0 128');
      });

      test('should handle empty list', () {
        expect(DataFormatter.toDecString([]), '');
      });

      test('should handle single byte', () {
        expect(DataFormatter.toDecString([42]), '42');
      });
    });

    group('toBinString', () {
      test('should format bytes as 8-bit binary', () {
        final bytes = [0x01, 0x80, 0xFF];
        expect(DataFormatter.toBinString(bytes), '00000001 10000000 11111111');
      });

      test('should handle zero', () {
        expect(DataFormatter.toBinString([0x00]), '00000000');
      });

      test('should handle empty list', () {
        expect(DataFormatter.toBinString([]), '');
      });
    });

    group('parseHexString', () {
      test('should parse space-separated hex', () {
        final result = DataFormatter.parseHexString('1A 2B FF');
        expect(result, [0x1A, 0x2B, 0xFF]);
      });

      test('should parse hex without spaces', () {
        final result = DataFormatter.parseHexString('1A2BFF');
        expect(result, [0x1A, 0x2B, 0xFF]);
      });

      test('should handle 0x prefix', () {
        final result = DataFormatter.parseHexString('0x1A 0x2B 0xFF');
        expect(result, [0x1A, 0x2B, 0xFF]);
      });

      test('should handle lowercase hex', () {
        final result = DataFormatter.parseHexString('1a 2b ff');
        expect(result, [0x1A, 0x2B, 0xFF]);
      });

      test('should pad odd-length hex with leading zero', () {
        final result = DataFormatter.parseHexString('ABC');
        expect(result, [0x0A, 0xBC]);
      });

      test('should handle empty string', () {
        final result = DataFormatter.parseHexString('');
        expect(result, []);
      });

      test('should return null for invalid hex', () {
        expect(DataFormatter.parseHexString('ZZZ'), isNull);
        expect(DataFormatter.parseHexString('Hello World'), isNull);
      });

      test('should handle leading/trailing whitespace', () {
        final result = DataFormatter.parseHexString('  1A 2B  ');
        expect(result, [0x1A, 0x2B]);
      });

      test('should handle 0x prefix with mixed case', () {
        final result = DataFormatter.parseHexString('0X1A 0x2B');
        expect(result, [0x1A, 0x2B]);
      });
    });

    group('isValidHexInput', () {
      test('should return true for valid hex', () {
        expect(DataFormatter.isValidHexInput('1A2B'), true);
        expect(DataFormatter.isValidHexInput('1A 2B FF'), true);
        expect(DataFormatter.isValidHexInput('0x1A 0x2B'), true);
      });

      test('should return true for empty or whitespace', () {
        expect(DataFormatter.isValidHexInput(''), true);
        expect(DataFormatter.isValidHexInput('   '), true);
      });

      test('should return false for odd-length hex', () {
        expect(DataFormatter.isValidHexInput('ABC'), false);
      });

      test('should return false for invalid chars', () {
        expect(DataFormatter.isValidHexInput('ZZZ'), false);
      });

      test('should return true for hex with 0x prefix', () {
        // After cleaning: 0x1A0x2B -> 1A2B (length 4, even)
        expect(DataFormatter.isValidHexInput('0x1A 0x2B'), true);
      });
    });

    group('bytesToUint16', () {
      test('should convert 2 bytes to uint16 (little-endian)', () {
        // 0x0201 = 513 in little-endian
        expect(DataFormatter.bytesToUint16([0x01, 0x02]), 0x0201);
      });

      test('should handle offset', () {
        final bytes = [0xFF, 0xFF, 0x34, 0x12];
        expect(DataFormatter.bytesToUint16(bytes, offset: 2), 0x1234);
      });

      test('should return 0 for insufficient bytes', () {
        expect(DataFormatter.bytesToUint16([0x01]), 0);
        expect(DataFormatter.bytesToUint16([]), 0);
      });

      test('should handle zero values', () {
        expect(DataFormatter.bytesToUint16([0x00, 0x00]), 0);
      });

      test('should handle max uint16', () {
        expect(DataFormatter.bytesToUint16([0xFF, 0xFF]), 0xFFFF);
      });
    });

    group('bytesToUint32', () {
      test('should convert 4 bytes to uint32 (little-endian)', () {
        // 0x04030201 in little-endian
        expect(
            DataFormatter.bytesToUint32([0x01, 0x02, 0x03, 0x04]), 0x04030201);
      });

      test('should handle offset', () {
        final bytes = [0x00, 0x00, 0x78, 0x56, 0x34, 0x12];
        expect(DataFormatter.bytesToUint32(bytes, offset: 2), 0x12345678);
      });

      test('should return 0 for insufficient bytes', () {
        expect(DataFormatter.bytesToUint32([0x01, 0x02, 0x03]), 0);
        expect(DataFormatter.bytesToUint32([0x01]), 0);
        expect(DataFormatter.bytesToUint32([]), 0);
      });

      test('should handle max uint32', () {
        expect(
          DataFormatter.bytesToUint32([0xFF, 0xFF, 0xFF, 0xFF]),
          0xFFFFFFFF,
        );
      });
    });

    group('formatLabels', () {
      test('should list all format labels', () {
        expect(DataFormatter.formatLabels, ['HEX', 'ASCII', 'DEC', 'BIN']);
      });
    });

    group('Roundtrip conversions', () {
      test('should roundtrip hex → bytes → hex', () {
        const original = '1A 2B FF 00';
        final bytes = DataFormatter.parseHexString(original);
        final result = DataFormatter.toHexString(bytes!);
        expect(result, original);
      });

      test('should roundtrip bytes → hex → bytes', () {
        const bytes = [0xDE, 0xAD, 0xBE, 0xEF];
        final hexStr = DataFormatter.toHexString(bytes);
        final result = DataFormatter.parseHexString(hexStr);
        expect(result, bytes);
      });

      test('should roundtrip binary → bytes → hex', () {
        final bytes = [0x42, 0x13, 0x37];
        final hexStr = DataFormatter.toHexString(bytes);
        final result = DataFormatter.parseHexString(hexStr);
        expect(result, bytes);
      });
    });
  });
}
