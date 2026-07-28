/// Global application constants.
class AppConstants {
  AppConstants._();

  // --- Log Limits ---
  static const int maxLogEntries = 100000;
  static const int maxLogSizeBytes = 100 * 1024 * 1024; // 100 MB

  // --- BLE ---
  static const int defaultScanDurationSeconds = 30;
  static const int defaultMtu = 23;
  static const int maxConcurrentDevices = 4;
  static const int connectTimeoutSeconds = 10;
  static const int operationTimeoutSeconds = 5;

  // --- App ---
  static const String appName = 'BLE Helper';
  static const String appVersion = '1.0.0';
  static const String logArchiveDir = 'ble_logs/archive';
  static const String logExportDir = 'ble_logs/exports';
}
