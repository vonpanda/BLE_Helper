/// Represents a GATT Descriptor within a Characteristic.
class BleDescriptorInfo {
  final String uuid;
  final String characteristicUuid;
  final String deviceId;
  final List<int>? value;

  const BleDescriptorInfo({
    required this.uuid,
    required this.characteristicUuid,
    required this.deviceId,
    this.value,
  });

  BleDescriptorInfo copyWith({
    String? uuid,
    String? characteristicUuid,
    String? deviceId,
    List<int>? value,
    bool clearValue = false,
  }) {
    return BleDescriptorInfo(
      uuid: uuid ?? this.uuid,
      characteristicUuid: characteristicUuid ?? this.characteristicUuid,
      deviceId: deviceId ?? this.deviceId,
      value: clearValue ? null : (value ?? this.value),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'characteristicUuid': characteristicUuid,
      'deviceId': deviceId,
      'value': value,
    };
  }

  factory BleDescriptorInfo.fromJson(Map<String, dynamic> json) {
    return BleDescriptorInfo(
      uuid: json['uuid'] as String,
      characteristicUuid: json['characteristicUuid'] as String,
      deviceId: json['deviceId'] as String,
      value: (json['value'] as List<dynamic>?)?.map((e) => e as int).toList(),
    );
  }

  @override
  String toString() => 'BleDescriptorInfo(uuid: $uuid)';
}
