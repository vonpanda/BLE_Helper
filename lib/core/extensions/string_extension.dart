/// Extension methods for String.
extension StringExtension on String {
  /// Capitalize the first character.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Truncate to a maximum length, appending "..." if truncated.
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// Check if this string is a valid MAC address (12 hex chars).
  bool get isValidMacAddress {
    final String cleaned = replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');
    return cleaned.length == 12;
  }

  /// Remove all whitespace characters.
  String get removeWhitespace {
    return replaceAll(RegExp(r'\s+'), '');
  }

  /// Returns null if the string is empty or whitespace only.
  String? get nullIfEmpty {
    final String trimmed = trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// Check if this string looks like a valid UUID.
  bool get isValidUuid {
    final RegExp uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidRegex.hasMatch(this);
  }
}
