import 'dart:io' show Platform;

import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

import 'platform_interface.dart';

/// Android platform implementation of [IPlatformHelper].
class AndroidPlatformHelper implements IPlatformHelper {
  AndroidPlatformHelper();

  @override
  Future<bool> requestBluetoothPermissions() async {
    try {
      // Android 12+ (API 31+) requires BLUETOOTH_SCAN and BLUETOOTH_CONNECT
      final Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();

      return statuses.values.every(
        (PermissionStatus s) => s == PermissionStatus.granted,
      );
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> requestLocationPermissions() async {
    try {
      // Location permission is needed for BLE scanning on Android < 12
      if (!await _isAndroid12OrAbove()) {
        final PermissionStatus status = await Permission.location.request();
        return status == PermissionStatus.granted;
      }
      return true; // Not required on Android 12+
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isBluetoothEnabled() async {
    try {
      return await Permission.bluetoothConnect.status ==
          PermissionStatus.granted;
    } catch (_) {
      // Delegate to runtime check if permissions API fails
      return true; // Assume enabled; the BLE library will surface real status
    }
  }

  @override
  Future<bool> enableBluetooth() async {
    // flutter_blue_plus provides its own BT enable dialog
    // Permission_handler can open system BT settings as a fallback
    try {
      await openAppSettings();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isLocationEnabled() async {
    try {
      final PermissionStatus status = await Permission.location.status;
      return status == PermissionStatus.granted;
    } catch (_) {
      return true;
    }
  }

  @override
  Future<String> getDeviceMacAddress() async {
    // Android restricts MAC address access for privacy; return a placeholder
    return '02:00:00:00:00:00';
  }

  @override
  Future<String> getAppDocumentsPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  @override
  Future<String> getAppCachePath() async {
    final dir = await getTemporaryDirectory();
    return dir.path;
  }

  @override
  Future<bool> isAndroid() async => true;

  @override
  Future<bool> isIOS() async => false;

  /// Check if the device is running Android 12 (API 31) or above.
  Future<bool> _isAndroid12OrAbove() async {
    // SDK 31 = Android 12
    return Platform.operatingSystemVersion.contains(RegExp(r'^[3-9][1-9]'));
  }
}
