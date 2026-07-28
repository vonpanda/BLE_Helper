import 'platform_interface.dart';

/// iOS platform stub — throws [UnsupportedError] for all operations.
/// To be replaced with a real iOS implementation when iOS support is added.
class IosPlatformStub implements IPlatformHelper {
  IosPlatformStub();

  @override
  Future<bool> requestBluetoothPermissions() async {
    throw UnsupportedError('iOS platform support is not yet implemented.');
  }

  @override
  Future<bool> requestLocationPermissions() async {
    throw UnsupportedError('iOS platform support is not yet implemented.');
  }

  @override
  Future<bool> isBluetoothEnabled() async {
    throw UnsupportedError('iOS platform support is not yet implemented.');
  }

  @override
  Future<bool> enableBluetooth() async {
    throw UnsupportedError('iOS platform support is not yet implemented.');
  }

  @override
  Future<bool> isLocationEnabled() async {
    throw UnsupportedError('iOS platform support is not yet implemented.');
  }

  @override
  Future<String> getDeviceMacAddress() async {
    throw UnsupportedError('iOS platform support is not yet implemented.');
  }

  @override
  Future<String> getAppDocumentsPath() async {
    throw UnsupportedError('iOS platform support is not yet implemented.');
  }

  @override
  Future<String> getAppCachePath() async {
    throw UnsupportedError('iOS platform support is not yet implemented.');
  }

  @override
  Future<bool> isAndroid() async => false;

  @override
  Future<bool> isIOS() async => true;
}
