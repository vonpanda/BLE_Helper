import 'advertisement_data.dart';

/// Represents a discovered or connected BLE device.
class BleDevice {
  final String id;
  final String name;
  final String macAddress;
  final int rssi;
  final DateTime lastSeen;
  final bool isConnected;
  final bool isFavorite;
  final AdvertisementData? advData;

  const BleDevice({
    required this.id,
    required this.name,
    required this.macAddress,
    required this.rssi,
    required this.lastSeen,
    this.isConnected = false,
    this.isFavorite = false,
    this.advData,
  });

  /// Create a [BleDevice] from a flutter_blue_plus [ScanResult].
  factory BleDevice.fromScanResult(
    dynamic scanResult, {
    bool isFavorite = false,
  }) {
    // scanResult is of type ScanResult from flutter_blue_plus
    final dynamic device = scanResult.device;
    final dynamic adv = scanResult.advertisementData;

    return BleDevice(
      id: device.remoteId.toString(),
      name: (adv?.advName?.isNotEmpty == true)
          ? adv!.advName
          : (device.platformName?.isNotEmpty == true)
              ? device.platformName
              : 'Unknown',
      macAddress: device.remoteId.toString(),
      rssi: scanResult.rssi ?? -100,
      lastSeen: DateTime.now(),
      isConnected: false,
      isFavorite: isFavorite,
      advData: adv != null ? AdvertisementData.fromFlutterBluePlus(adv) : null,
    );
  }

  /// Create a copy with some fields replaced.
  BleDevice copyWith({
    String? id,
    String? name,
    String? macAddress,
    int? rssi,
    DateTime? lastSeen,
    bool? isConnected,
    bool? isFavorite,
    AdvertisementData? advData,
  }) {
    return BleDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      macAddress: macAddress ?? this.macAddress,
      rssi: rssi ?? this.rssi,
      lastSeen: lastSeen ?? this.lastSeen,
      isConnected: isConnected ?? this.isConnected,
      isFavorite: isFavorite ?? this.isFavorite,
      advData: advData ?? this.advData,
    );
  }

  /// Serialize to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'macAddress': macAddress,
      'rssi': rssi,
      'lastSeen': lastSeen.toIso8601String(),
      'isConnected': isConnected,
      'isFavorite': isFavorite,
      'advData': advData?.toJson(),
    };
  }

  /// Deserialize from JSON.
  factory BleDevice.fromJson(Map<String, dynamic> json) {
    return BleDevice(
      id: json['id'] as String,
      name: json['name'] as String,
      macAddress: json['macAddress'] as String,
      rssi: json['rssi'] as int,
      lastSeen: DateTime.parse(json['lastSeen'] as String),
      isConnected: json['isConnected'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
      advData: json['advData'] != null
          ? AdvertisementData.fromJson(json['advData'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  String toString() => 'BleDevice(id: $id, name: $name, rssi: $rssi)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BleDevice && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
