import '../database/app_database.dart';
import '../models/ble_device.dart';

/// Repository for managing favorite devices and connection history.
class DeviceRepository {
  final AppDatabase _db;

  DeviceRepository({required AppDatabase database}) : _db = database;

  /// Get all favorite devices as [BleDevice] objects.
  Future<List<BleDevice>> getFavoriteDevices() async {
    try {
      final List<FavoriteDevice> rows = await _db.deviceDao.getAllFavorites();
      return rows.map((row) {
        final Map<String, dynamic> json = _parseSimpleJson(row.deviceJson);
        return BleDevice.fromJson(json);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Add a device to favorites.
  Future<void> addFavorite(BleDevice device) async {
    try {
      await _db.deviceDao.addFavorite(
        FavoriteDevicesCompanion.insert(
          deviceId: device.id,
          name: device.name,
          macAddress: device.macAddress,
          lastSeen: device.lastSeen.toUtc().toIso8601String(),
          deviceJson: _deviceToJsonString(device),
        ),
      );
    } catch (_) {
      // Silently ignore — favorites are non-critical
    }
  }

  /// Remove a device from favorites.
  Future<void> removeFavorite(String deviceId) async {
    try {
      await _db.deviceDao.removeFavorite(deviceId);
    } catch (_) {}
  }

  /// Check if a device is favorited.
  Future<bool> isFavorite(String deviceId) async {
    try {
      return await _db.deviceDao.isFavorite(deviceId);
    } catch (_) {
      return false;
    }
  }

  /// Get connection history as [BleDevice] list.
  Future<List<BleDevice>> getConnectionHistory() async {
    try {
      final List<ConnectionHistoryData> rows =
          await _db.deviceDao.getConnectionHistory(limit: 50);
      // Deduplicate by deviceId, keeping the most recent entry
      final Map<String, BleDevice> seen = {};
      for (final row in rows) {
        if (!seen.containsKey(row.deviceId)) {
          seen[row.deviceId] = BleDevice(
            id: row.deviceId,
            name: row.name,
            macAddress: row.macAddress,
            rssi: -100,
            lastSeen: row.disconnectedAt != null
                ? DateTime.tryParse(row.disconnectedAt!) ?? DateTime.now()
                : DateTime.tryParse(row.connectedAt) ?? DateTime.now(),
          );
        }
      }
      return seen.values.toList();
    } catch (e) {
      return [];
    }
  }

  /// Record a connection event.
  Future<void> recordConnection(BleDevice device) async {
    try {
      await _db.deviceDao.recordConnection(
        ConnectionHistoryCompanion.insert(
          deviceId: device.id,
          name: device.name,
          macAddress: device.macAddress,
          connectedAt: DateTime.now().toUtc().toIso8601String(),
        ),
      );
    } catch (_) {}
  }

  /// Record device disconnection.
  Future<void> recordDisconnection(String deviceId) async {
    try {
      final ConnectionHistoryData? lastConnection =
          await _db.deviceDao.getLastConnection(deviceId);
      if (lastConnection != null && lastConnection.disconnectedAt == null) {
        await _db.deviceDao.updateDisconnection(
          lastConnection.id,
          DateTime.now().toUtc().toIso8601String(),
        );
      }
    } catch (_) {}
  }

  /// Simple JSON parser (avoids dependency on dart:convert wrapping).
  Map<String, dynamic> _parseSimpleJson(String json) {
    // Use a simple approach — serialize via BleDevice.toJson
    // In this case, deviceJson is stored as a simple key-value format
    final Map<String, dynamic> result = <String, dynamic>{};
    final List<String> parts = json.split('|');
    for (final String part in parts) {
      final int colonIdx = part.indexOf(':');
      if (colonIdx > 0) {
        final String key = part.substring(0, colonIdx);
        final String value = part.substring(colonIdx + 1);
        result[key] = value;
      }
    }
    // Fall back to a minimal representation
    result['id'] ??= '';
    result['name'] ??= 'Unknown';
    result['macAddress'] ??= '';
    result['rssi'] ??= '-100';
    result['lastSeen'] ??= DateTime.now().toIso8601String();
    result['isFavorite'] ??= 'true';
    return result;
  }

  String _deviceToJsonString(BleDevice device) {
    final Map<String, dynamic> jsonMap = device.toJson();
    return jsonMap.entries.map((e) => '${e.key}:${e.value}').join('|');
  }
}
