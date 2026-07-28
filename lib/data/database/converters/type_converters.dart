import 'package:drift/drift.dart';

/// Custom Drift type converters for non-primitive types stored in the database.
///

/// Converts [DateTime] to/from ISO 8601 UTC string for SQLite storage.
class DateTimeConverter extends TypeConverter<DateTime, String> {
  const DateTimeConverter();

  @override
  DateTime fromSql(String fromDb) {
    return DateTime.parse(fromDb).toLocal();
  }

  @override
  String toSql(DateTime value) {
    return value.toUtc().toIso8601String();
  }
}

/// Converts a [List<String>] to/from a comma-separated string.
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    return fromDb.split(',');
  }

  @override
  String toSql(List<String> value) {
    return value.join(',');
  }
}
