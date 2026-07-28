import 'dart:typed_data';

/// Parsed BLE advertisement / scan response data.
class AdvertisementData {
  final String? localName;
  final int? txPowerLevel;
  final bool isConnectable;
  final int? manufacturerId;
  final List<int> manufacturerData;
  final Map<int, List<int>> serviceData;
  final List<String> serviceUuids;
  final Map<String, List<int>> parsedStructures;

  const AdvertisementData({
    this.localName,
    this.txPowerLevel,
    this.isConnectable = true,
    this.manufacturerId,
    this.manufacturerData = const [],
    this.serviceData = const {},
    this.serviceUuids = const [],
    this.parsedStructures = const {},
  });

  /// Create from flutter_blue_plus's AdvertisementData.
  factory AdvertisementData.fromFlutterBluePlus(dynamic adv) {
    final dynamic manufacturerDataRaw =
        _tryRead<dynamic>(() => adv.manufacturerData);
    final MapEntry<int, List<int>>? manufacturer =
        _firstManufacturerData(manufacturerDataRaw);
    final List<String> uuids =
        _parseServiceUuids(_tryRead<dynamic>(() => adv.serviceUuids));

    return AdvertisementData(
      localName: _tryRead<String?>(() => adv.advName) ??
          _tryRead<String?>(() => adv.localName),
      txPowerLevel: _parseInt(_tryRead<dynamic>(() => adv.txPowerLevel)),
      isConnectable: _tryRead<bool?>(() => adv.connectable) ?? true,
      manufacturerId:
          _tryRead<int?>(() => adv.manufacturerId) ?? manufacturer?.key,
      manufacturerData:
          manufacturer?.value ?? _parseByteList(manufacturerDataRaw),
      serviceData: _parseServiceData(_tryRead<dynamic>(() => adv.serviceData)),
      serviceUuids: uuids,
    );
  }

  /// Parse raw advertisement bytes into AD structures.
  factory AdvertisementData.parse(List<int> raw) {
    String? localName;
    int? txPowerLevel;
    final List<String> serviceUuids = [];
    final Map<String, List<int>> structures = {};

    int i = 0;
    while (i < raw.length) {
      final int length = raw[i];
      if (length == 0 || i + length >= raw.length) break;

      final int type = raw[i + 1];
      final List<int> data = raw.sublist(i + 2, i + 1 + length);
      final String key =
          'AD_TYPE_0x${type.toRadixString(16).padLeft(2, '0').toUpperCase()}';

      switch (type) {
        case 0x01: // Flags
          structures['Flags'] = data;
          break;
        case 0x02: // Incomplete 16-bit UUIDs
        case 0x03: // Complete 16-bit UUIDs
          for (int j = 0; j < data.length - 1; j += 2) {
            final String uuid =
                '0000${data[j + 1].toRadixString(16).padLeft(2, '0')}${data[j].toRadixString(16).padLeft(2, '0')}-0000-1000-8000-00805F9B34FB';
            serviceUuids.add(uuid.toUpperCase());
          }
          break;
        case 0x08: // Shortened Local Name
        case 0x09: // Complete Local Name
          localName = String.fromCharCodes(data);
          break;
        case 0x0A: // TX Power Level
          txPowerLevel = data.isNotEmpty ? data[0] : null;
          break;
        case 0xFF: // Manufacturer Specific
          structures['ManufacturerSpecific'] = data;
          break;
        default:
          structures[key] = data;
          break;
      }
      i += length + 1;
    }

    return AdvertisementData(
      localName: localName,
      txPowerLevel: txPowerLevel,
      serviceUuids: serviceUuids,
      parsedStructures: structures,
    );
  }

  static T? _tryRead<T>(T Function() read) {
    try {
      return read();
    } on NoSuchMethodError {
      return null;
    } on TypeError {
      return null;
    }
  }

  static int? _parseInt(dynamic raw, {int? radix}) {
    if (raw == null) return null;
    if (raw is int) return raw;
    return int.tryParse(raw.toString(), radix: radix);
  }

  static List<int> _parseByteList(dynamic raw) {
    if (raw is Uint8List) return List<int>.from(raw);
    if (raw is List<int>) return List<int>.from(raw);
    if (raw is List) {
      return raw.whereType<int>().toList();
    }
    return [];
  }

  static MapEntry<int, List<int>>? _firstManufacturerData(dynamic raw) {
    if (raw is Map && raw.isNotEmpty) {
      for (final dynamic entry in raw.entries) {
        final int? id = _parseInt(entry.key);
        final List<int> bytes = _parseByteList(entry.value);
        if (id != null) {
          return MapEntry<int, List<int>>(id, bytes);
        }
      }
    }
    return null;
  }

  static List<String> _parseServiceUuids(dynamic raw) {
    if (raw is Iterable) {
      return raw.map((u) => u.toString()).toList();
    }
    return [];
  }

  static Map<int, List<int>> _parseServiceData(dynamic raw) {
    if (raw == null) return {};
    final Map<int, List<int>> result = {};
    if (raw is Map) {
      for (final dynamic entry in raw.entries) {
        final dynamic key = entry.key;
        final dynamic value = entry.value;
        final int? parsedKey =
            _parseInt(key) ?? _parseInt(key.toString(), radix: 16);
        if (parsedKey != null && value != null) {
          result[parsedKey] = _parseByteList(value);
        }
      }
    }
    return result;
  }

  Map<String, dynamic> toJson() {
    return {
      'localName': localName,
      'txPowerLevel': txPowerLevel,
      'isConnectable': isConnectable,
      'manufacturerId': manufacturerId,
      'manufacturerData': manufacturerData,
      'serviceUuids': serviceUuids,
    };
  }

  factory AdvertisementData.fromJson(Map<String, dynamic> json) {
    return AdvertisementData(
      localName: json['localName'] as String?,
      txPowerLevel: json['txPowerLevel'] as int?,
      isConnectable: json['isConnectable'] as bool? ?? true,
      manufacturerId: json['manufacturerId'] as int?,
      manufacturerData: (json['manufacturerData'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      serviceUuids: (json['serviceUuids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  @override
  String toString() =>
      'AdvertisementData(name: $localName, uuids: ${serviceUuids.length})';
}
