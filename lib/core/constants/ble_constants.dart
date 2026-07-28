/// BLE-related constants including standard UUIDs and filter presets.
class BleConstants {
  BleConstants._();

  // --- Standard GATT UUIDs (16-bit) ---
  static const String genericAccessService =
      '00001800-0000-1000-8000-00805f9b34fb';
  static const String genericAttributeService =
      '00001801-0000-1000-8000-00805f9b34fb';
  static const String deviceInformationService =
      '0000180a-0000-1000-8000-00805f9b34fb';
  static const String batteryService = '0000180f-0000-1000-8000-00805f9b34fb';
  static const String nordicDfuService = '00001530-1212-efde-1523-785feabcd123';

  // --- Standard Characteristic UUIDs ---
  static const String deviceNameCharacteristic =
      '00002a00-0000-1000-8000-00805f9b34fb';
  static const String appearanceCharacteristic =
      '00002a01-0000-1000-8000-00805f9b34fb';
  static const String batteryLevelCharacteristic =
      '00002a19-0000-1000-8000-00805f9b34fb';

  // --- UUID Format ---
  static const int uuid16BitLength = 4;
  static const int uuid32BitLength = 8;
  static const int uuid128BitLength = 16;

  // --- Default filter values ---
  static const int defaultRssiMin = -90;
}
