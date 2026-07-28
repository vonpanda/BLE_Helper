import 'scan_filter.dart';

/// Types of events that can be logged.
enum LogEventType {
  SCAN_DEVICE_FOUND,
  DEVICE_CONNECTED,
  DEVICE_DISCONNECTED,
  GATT_READ,
  GATT_WRITE,
  GATT_NOTIFY,
  GATT_INDICATE,
  MTU_CHANGED,
  ERROR,
  DFU_STARTED,
  DFU_PROGRESS,
  DFU_COMPLETED,
}

/// Direction of data flow for GATT operations.
enum LogDirection {
  TX,
  RX,
}

/// A single log entry recording BLE activity.
class LogEntry {
  final int? id;
  final DateTime timestamp;
  final String deviceId;
  final String? deviceName;
  final LogEventType eventType;
  final LogDirection? direction;
  final String? serviceUuid;
  final String? characteristicUuid;
  final String? dataHex;
  final String description;
  final String? errorDetail;

  const LogEntry({
    this.id,
    required this.timestamp,
    required this.deviceId,
    this.deviceName,
    required this.eventType,
    this.direction,
    this.serviceUuid,
    this.characteristicUuid,
    this.dataHex,
    required this.description,
    this.errorDetail,
  });

  LogEntry copyWith({
    int? id,
    DateTime? timestamp,
    String? deviceId,
    String? deviceName,
    LogEventType? eventType,
    LogDirection? direction,
    String? serviceUuid,
    String? characteristicUuid,
    String? dataHex,
    String? description,
    String? errorDetail,
    bool clearDeviceName = false,
    bool clearServiceUuid = false,
    bool clearCharacteristicUuid = false,
    bool clearDataHex = false,
    bool clearErrorDetail = false,
  }) {
    return LogEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      deviceId: deviceId ?? this.deviceId,
      deviceName: clearDeviceName ? null : (deviceName ?? this.deviceName),
      eventType: eventType ?? this.eventType,
      direction: direction ?? this.direction,
      serviceUuid: clearServiceUuid ? null : (serviceUuid ?? this.serviceUuid),
      characteristicUuid: clearCharacteristicUuid
          ? null
          : (characteristicUuid ?? this.characteristicUuid),
      dataHex: clearDataHex ? null : (dataHex ?? this.dataHex),
      description: description ?? this.description,
      errorDetail: clearErrorDetail ? null : (errorDetail ?? this.errorDetail),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'deviceId': deviceId,
      'deviceName': deviceName,
      'eventType': eventType.name,
      'direction': direction?.name,
      'serviceUuid': serviceUuid,
      'characteristicUuid': characteristicUuid,
      'dataHex': dataHex,
      'description': description,
      'errorDetail': errorDetail,
    };
  }

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: json['id'] as int?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      deviceId: json['deviceId'] as String,
      deviceName: json['deviceName'] as String?,
      eventType: LogEventType.values.firstWhere(
        (e) => e.name == json['eventType'],
        orElse: () => LogEventType.ERROR,
      ),
      direction: json['direction'] != null
          ? LogDirection.values.firstWhere((e) => e.name == json['direction'])
          : null,
      serviceUuid: json['serviceUuid'] as String?,
      characteristicUuid: json['characteristicUuid'] as String?,
      dataHex: json['dataHex'] as String?,
      description: json['description'] as String,
      errorDetail: json['errorDetail'] as String?,
    );
  }

  /// Short summary of this log entry for list display.
  String get summary {
    final StringBuffer sb = StringBuffer();
    sb.write(eventType.name);
    if (deviceName != null) {
      sb.write(' - $deviceName');
    }
    if (dataHex != null && dataHex!.isNotEmpty) {
      sb.write(
          ' [${dataHex!.substring(0, dataHex!.length > 16 ? 16 : dataHex!.length)}]');
    }
    return sb.toString();
  }

  @override
  String toString() => 'LogEntry(#$id, $eventType, $description)';
}

/// Query parameters for filtering log entries.
class LogQuery {
  final LogEventType? eventType;
  final String? deviceId;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? searchText;
  final int? limit;
  final int? offset;
  final LogSortField sortField;
  final SortOrder sortOrder;

  const LogQuery({
    this.eventType,
    this.deviceId,
    this.startTime,
    this.endTime,
    this.searchText,
    this.limit,
    this.offset,
    this.sortField = LogSortField.TIMESTAMP,
    this.sortOrder = SortOrder.DESC,
  });

  LogQuery copyWith({
    LogEventType? eventType,
    String? deviceId,
    DateTime? startTime,
    DateTime? endTime,
    String? searchText,
    int? limit,
    int? offset,
    LogSortField? sortField,
    SortOrder? sortOrder,
  }) {
    return LogQuery(
      eventType: eventType ?? this.eventType,
      deviceId: deviceId ?? this.deviceId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      searchText: searchText ?? this.searchText,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      sortField: sortField ?? this.sortField,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

/// Fields by which logs can be sorted.
enum LogSortField {
  TIMESTAMP,
  EVENT_TYPE,
  DEVICE_NAME,
}

/// Format options for log export.
enum LogExportFormat {
  TXT,
  CSV,
  JSON,
}

/// Statistics about the log database.
class LogStats {
  final int totalEntries;
  final int totalSizeBytes;
  final DateTime oldestEntry;
  final DateTime newestEntry;
  final Map<LogEventType, int> typeDistribution;

  const LogStats({
    required this.totalEntries,
    required this.totalSizeBytes,
    required this.oldestEntry,
    required this.newestEntry,
    required this.typeDistribution,
  });

  @override
  String toString() =>
      'LogStats(entries: $totalEntries, size: $totalSizeBytes, types: ${typeDistribution.length})';
}
