/// Platform abstraction interface for OS-specific operations.
abstract class IPlatformHelper {
  /// Request Bluetooth-related permissions (BLUETOOTH_CONNECT, BLUETOOTH_SCAN).
  Future<bool> requestBluetoothPermissions();

  /// Request location permissions (required for BLE scanning on Android < 12).
  Future<bool> requestLocationPermissions();

  /// Check if Bluetooth is currently enabled.
  Future<bool> isBluetoothEnabled();

  /// Prompt user to enable Bluetooth (may not work on all platforms).
  Future<bool> enableBluetooth();

  /// Check if Location services are enabled.
  Future<bool> isLocationEnabled();

  /// Get the device's own MAC address (if available).
  Future<String> getDeviceMacAddress();

  /// Get the app's documents directory path.
  Future<String> getAppDocumentsPath();

  /// Get the app's cache directory path.
  Future<String> getAppCachePath();

  /// Whether the current platform is Android.
  Future<bool> isAndroid();

  /// Whether the current platform is iOS.
  Future<bool> isIOS();
}
