import 'ble_descriptor.dart';

/// Represents the properties (permissions) of a GATT Characteristic.
class CharacteristicProperties {
  final bool read;
  final bool write;
  final bool writeWithoutResponse;
  final bool notify;
  final bool indicate;

  const CharacteristicProperties({
    this.read = false,
    this.write = false,
    this.writeWithoutResponse = false,
    this.notify = false,
    this.indicate = false,
  });

  /// Build from a list of property strings provided by flutter_blue_plus.
  factory CharacteristicProperties.fromFlags(List<String> flags) {
    return CharacteristicProperties(
      read: flags.contains('read'),
      write: flags.contains('write'),
      writeWithoutResponse: flags.contains('writeWithoutResponse'),
      notify: flags.contains('notify'),
      indicate: flags.contains('indicate'),
    );
  }

  /// Properties that involve sending data to the device.
  bool get canWrite => write || writeWithoutResponse;

  /// List of human-readable property labels.
  List<String> get labels {
    final List<String> result = [];
    if (read) result.add('READ');
    if (write) result.add('WRITE');
    if (writeWithoutResponse) result.add('WRITE_NO_RESP');
    if (notify) result.add('NOTIFY');
    if (indicate) result.add('INDICATE');
    return result;
  }

  Map<String, dynamic> toJson() {
    return {
      'read': read,
      'write': write,
      'writeWithoutResponse': writeWithoutResponse,
      'notify': notify,
      'indicate': indicate,
    };
  }

  factory CharacteristicProperties.fromJson(Map<String, dynamic> json) {
    return CharacteristicProperties(
      read: json['read'] as bool? ?? false,
      write: json['write'] as bool? ?? false,
      writeWithoutResponse: json['writeWithoutResponse'] as bool? ?? false,
      notify: json['notify'] as bool? ?? false,
      indicate: json['indicate'] as bool? ?? false,
    );
  }

  @override
  String toString() => 'CharacteristicProperties(${labels.join(', ')})';
}

/// Represents a GATT Characteristic within a Service.
class BleCharacteristicInfo {
  final String uuid;
  final String serviceUuid;
  final String deviceId;
  final CharacteristicProperties properties;
  final List<int>? lastReadValue;
  final List<int>? lastNotifyValue;
  final bool isNotifying;
  final bool isIndicating;
  final List<BleDescriptorInfo> descriptors;

  const BleCharacteristicInfo({
    required this.uuid,
    required this.serviceUuid,
    required this.deviceId,
    required this.properties,
    this.lastReadValue,
    this.lastNotifyValue,
    this.isNotifying = false,
    this.isIndicating = false,
    this.descriptors = const [],
  });

  BleCharacteristicInfo copyWith({
    String? uuid,
    String? serviceUuid,
    String? deviceId,
    CharacteristicProperties? properties,
    List<int>? lastReadValue,
    List<int>? lastNotifyValue,
    bool? isNotifying,
    bool? isIndicating,
    List<BleDescriptorInfo>? descriptors,
    bool clearReadValue = false,
    bool clearNotifyValue = false,
  }) {
    return BleCharacteristicInfo(
      uuid: uuid ?? this.uuid,
      serviceUuid: serviceUuid ?? this.serviceUuid,
      deviceId: deviceId ?? this.deviceId,
      properties: properties ?? this.properties,
      lastReadValue:
          clearReadValue ? null : (lastReadValue ?? this.lastReadValue),
      lastNotifyValue:
          clearNotifyValue ? null : (lastNotifyValue ?? this.lastNotifyValue),
      isNotifying: isNotifying ?? this.isNotifying,
      isIndicating: isIndicating ?? this.isIndicating,
      descriptors: descriptors ?? this.descriptors,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'serviceUuid': serviceUuid,
      'deviceId': deviceId,
      'properties': properties.toJson(),
      'lastReadValue': lastReadValue,
      'lastNotifyValue': lastNotifyValue,
      'isNotifying': isNotifying,
      'isIndicating': isIndicating,
      'descriptors': descriptors.map((d) => d.toJson()).toList(),
    };
  }

  factory BleCharacteristicInfo.fromJson(Map<String, dynamic> json) {
    return BleCharacteristicInfo(
      uuid: json['uuid'] as String,
      serviceUuid: json['serviceUuid'] as String,
      deviceId: json['deviceId'] as String,
      properties: CharacteristicProperties.fromJson(
        json['properties'] as Map<String, dynamic>,
      ),
      lastReadValue: (json['lastReadValue'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      lastNotifyValue: (json['lastNotifyValue'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      isNotifying: json['isNotifying'] as bool? ?? false,
      isIndicating: json['isIndicating'] as bool? ?? false,
      descriptors: (json['descriptors'] as List<dynamic>?)
              ?.map(
                  (d) => BleDescriptorInfo.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  String toString() => 'BleCharacteristicInfo(uuid: $uuid)';
}
