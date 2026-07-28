import 'package:intl/intl.dart';

/// Extension methods for DateTime.
extension DateTimeExtension on DateTime {
  /// Format as "yyyy-MM-dd HH:mm:ss" local time.
  String get toDisplayString {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(toLocal());
  }

  /// Format as "HH:mm:ss.SSS" for log timestamps.
  String get toLogTime {
    return DateFormat('HH:mm:ss.SSS').format(toLocal());
  }

  /// Format as ISO 8601 UTC string for database storage.
  String get toIso8601Utc {
    return DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(toUtc());
  }

  /// Format as short date "MM-dd HH:mm".
  String get toShortString {
    return DateFormat('MM-dd HH:mm').format(toLocal());
  }
}
