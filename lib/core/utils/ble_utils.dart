/// BLE utility functions such as UUID normalization and RSSI quality assessment.
class BleUtils {
  BleUtils._();

  /// Normalize a UUID string to the standard 128-bit format
  /// (e.g., "1800" → "00001800-0000-1000-8000-00805f9b34fb").
  static String normalizeUuid(String uuid) {
    final String cleaned = uuid.replaceAll('-', '').toUpperCase();

    if (cleaned.length == 4) {
      return '0000$cleaned-0000-1000-8000-00805F9B34FB';
    } else if (cleaned.length == 8) {
      return '$cleaned-0000-1000-8000-00805F9B34FB';
    } else if (cleaned.length == 32) {
      return '${cleaned.substring(0, 8)}-'
          '${cleaned.substring(8, 12)}-'
          '${cleaned.substring(12, 16)}-'
          '${cleaned.substring(16, 20)}-'
          '${cleaned.substring(20, 32)}';
    }
    return uuid;
  }

  /// Shorten a 128-bit UUID to a readable short form (e.g. "0x1800").
  static String shortenUuid(String uuid) {
    final String cleaned = uuid.replaceAll('-', '').toUpperCase();
    if (cleaned.length == 32) {
      // Check if it's a standard Bluetooth SIG base UUID
      if (cleaned.endsWith('00001000800000805F9B34FB')) {
        return '0x${cleaned.substring(0, 4)}';
      }
    }
    return uuid.length > 18 ? '${uuid.substring(0, 8)}...' : uuid;
  }

  /// Map an RSSI value to a human-readable quality label.
  static String rssiToLabel(int rssi) {
    if (rssi >= -50) return 'Excellent';
    if (rssi >= -65) return 'Good';
    if (rssi >= -80) return 'Fair';
    return 'Poor';
  }

  /// Map an RSSI value to a percentage (approx signal strength).
  static double rssiToPercent(int rssi) {
    // Rough mapping: -30 (100%) to -100 (0%)
    return ((rssi + 100) / 70).clamp(0.0, 1.0);
  }

  /// Convert a MAC address string to a standardized colon-separated format.
  static String formatMacAddress(String mac) {
    final String cleaned =
        mac.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '').toUpperCase();
    if (cleaned.length != 12) return mac;
    final List<String> parts = [];
    for (int i = 0; i < 12; i += 2) {
      parts.add(cleaned.substring(i, i + 2));
    }
    return parts.join(':');
  }
}
