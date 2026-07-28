import 'ble_characteristic.dart';

/// Represents a GATT Service discovered on a BLE device.
class BleServiceInfo {
  final String uuid;
  final String deviceId;
  final bool isPrimary;
  final List<BleCharacteristicInfo> characteristics;

  const BleServiceInfo({
    required this.uuid,
    required this.deviceId,
    required this.isPrimary,
    this.characteristics = const [],
  });

  BleServiceInfo copyWith({
    String? uuid,
    String? deviceId,
    bool? isPrimary,
    List<BleCharacteristicInfo>? characteristics,
  }) {
    return BleServiceInfo(
      uuid: uuid ?? this.uuid,
      deviceId: deviceId ?? this.deviceId,
      isPrimary: isPrimary ?? this.isPrimary,
      characteristics: characteristics ?? this.characteristics,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'deviceId': deviceId,
      'isPrimary': isPrimary,
      'characteristics': characteristics.map((c) => c.toJson()).toList(),
    };
  }

  factory BleServiceInfo.fromJson(Map<String, dynamic> json) {
    return BleServiceInfo(
      uuid: json['uuid'] as String,
      deviceId: json['deviceId'] as String,
      isPrimary: json['isPrimary'] as bool,
      characteristics: (json['characteristics'] as List<dynamic>?)
              ?.map((c) =>
                  BleCharacteristicInfo.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  String toString() =>
      'BleServiceInfo(uuid: $uuid, characteristics: ${characteristics.length})';
}
