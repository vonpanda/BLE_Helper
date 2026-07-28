/// Utility functions for formatting/parsing data between Hex, ASCII, Decimal, and Binary representations.
class DataFormatter {
  DataFormatter._();

  /// Supported data display formats.
  static const List<String> formatLabels = ['HEX', 'ASCII', 'DEC', 'BIN'];

  /// Format a byte list as space-separated Hex string (e.g. "1A 2B FF").
  static String toHexString(List<int> bytes, {bool withPrefix = false}) {
    return bytes
        .map((b) => withPrefix
            ? '0x${b.toRadixString(16).padLeft(2, '0').toUpperCase()}'
            : b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(' ');
  }

  /// Format a byte list as ASCII string (non-printable chars replaced with '.').
  static String toAsciiString(List<int> bytes) {
    return String.fromCharCodes(
      bytes.map((b) => (b >= 32 && b <= 126) ? b : 46), // 46 = '.'
    );
  }

  /// Format a byte list as space-separated Decimal values.
  static String toDecString(List<int> bytes) {
    return bytes.map((b) => b.toString()).join(' ');
  }

  /// Format a byte list as space-separated Binary strings.
  static String toBinString(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(2).padLeft(8, '0')).join(' ');
  }

  /// Parse a Hex string (with or without spaces, with or without "0x" prefix)
  /// into a list of bytes.
  /// Returns null if the input is not valid hex.
  static List<int>? parseHexString(String hex) {
    try {
      // Remove "0x" prefixes and all whitespace
      String cleaned = hex
          .replaceAll(RegExp(r'0x', caseSensitive: false), '')
          .replaceAll(RegExp(r'\s+'), '');
      if (cleaned.isEmpty) return [];
      if (cleaned.length % 2 != 0) {
        cleaned = '0$cleaned'; // pad leading zero
      }
      final List<int> result = [];
      for (int i = 0; i < cleaned.length; i += 2) {
        result.add(int.parse(cleaned.substring(i, i + 2), radix: 16));
      }
      return result;
    } catch (_) {
      return null;
    }
  }

  /// Check whether a string looks like valid hex input.
  static bool isValidHexInput(String input) {
    if (input.trim().isEmpty) return true;
    final String cleaned = input
        .replaceAll(RegExp(r'0x', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), '');
    if (cleaned.isEmpty) return true;
    return RegExp(r'^[0-9A-Fa-f]+$').hasMatch(cleaned) &&
        cleaned.length % 2 == 0;
  }

  /// Merge consecutive bytes into a 16-bit unsigned integer (little-endian).
  static int bytesToUint16(List<int> bytes, {int offset = 0}) {
    if (bytes.length < offset + 2) return 0;
    return (bytes[offset + 1] << 8) | bytes[offset];
  }

  /// Merge consecutive bytes into a 32-bit unsigned integer (little-endian).
  static int bytesToUint32(List<int> bytes, {int offset = 0}) {
    if (bytes.length < offset + 4) return 0;
    return (bytes[offset + 3] << 24) |
        (bytes[offset + 2] << 16) |
        (bytes[offset + 1] << 8) |
        bytes[offset];
  }
}
