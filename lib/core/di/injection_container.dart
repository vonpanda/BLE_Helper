import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/device_repository.dart';
import '../../data/repositories/log_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../services/ble/ble_service_interface.dart';
import '../../services/ble/ble_service.dart';
import '../../services/ble/ble_device_manager.dart';
import '../../services/log/log_service.dart';
import '../../services/log/log_cleanup_worker.dart';
import '../../services/dfu/nordic_dfu_adapter.dart';
import '../../services/dfu/dfu_manager.dart';
import '../../services/dfu/dfu_firmware_parser.dart';
import '../../services/platform/platform_interface.dart';
import '../../services/platform/platform_android.dart';
import '../../services/platform/platform_ios_stub.dart';
import '../../bloc/scan/scan_bloc.dart';
import '../../bloc/device/device_bloc.dart';
import '../../bloc/gatt/gatt_bloc.dart';
import '../../bloc/log/log_bloc.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../../bloc/dfu/dfu_bloc.dart';

/// Global service locator instance.
final GetIt sl = GetIt.instance;

/// Register all dependencies in the GetIt service locator.
Future<void> configureDependencies() async {
  // ================================================================
  // Platform Helper (singleton, per-platform)
  // ================================================================
  if (kIsWeb) {
    sl.registerLazySingleton<IPlatformHelper>(() => IosPlatformStub());
  } else if (Platform.isAndroid) {
    sl.registerLazySingleton<IPlatformHelper>(() => AndroidPlatformHelper());
  } else if (Platform.isIOS) {
    sl.registerLazySingleton<IPlatformHelper>(() => IosPlatformStub());
  } else {
    sl.registerLazySingleton<IPlatformHelper>(() => AndroidPlatformHelper());
  }

  // ================================================================
  // SharedPreferences (singleton, must be awaited)
  // ================================================================
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  // ================================================================
  // Database (singleton)
  // ================================================================
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // ================================================================
  // Repositories
  // ================================================================
  sl.registerLazySingleton<DeviceRepository>(
    () => DeviceRepository(database: sl<AppDatabase>()),
  );
  sl.registerLazySingleton<LogRepository>(
    () => LogRepository(database: sl<AppDatabase>()),
  );
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepository(prefs: sl<SharedPreferences>()),
  );

  // ================================================================
  // BLE Services
  // ================================================================
  sl.registerLazySingleton<IBleService>(() => BleService());
  sl.registerLazySingleton<BleDeviceManager>(
    () => BleDeviceManager(
      bleService: sl<IBleService>(),
      maxConcurrentDevices: AppConstants.maxConcurrentDevices,
    ),
  );

  // ================================================================
  // Log Services
  // ================================================================
  sl.registerLazySingleton<LogCleanupWorker>(
    () => LogCleanupWorker(
      repository: sl<LogRepository>(),
      maxEntries: AppConstants.maxLogEntries,
      maxSizeBytes: AppConstants.maxLogSizeBytes,
    ),
  );
  sl.registerLazySingleton<LogService>(
    () => LogService(
      repository: sl<LogRepository>(),
      cleanupWorker: sl<LogCleanupWorker>(),
      maxEntries: AppConstants.maxLogEntries,
    ),
  );

  // ================================================================
  // DFU Services
  // ================================================================
  sl.registerLazySingleton<DfuFirmwareParser>(() => DfuFirmwareParser());
  sl.registerLazySingleton<DfuManager>(() => DfuManager());

  // Register Nordic DFU adapter (more adapters can be added later)
  final DfuManager dfuManager = sl<DfuManager>();
  dfuManager.registerAdapter(NordicDfuAdapter());

  // ================================================================
  // BLoCs (factory — new instance each time)
  // ================================================================
  sl.registerFactory<ScanBloc>(
    () => ScanBloc(
      bleService: sl<IBleService>(),
      logService: sl<LogService>(),
    ),
  );

  sl.registerFactoryParam<DeviceBloc, String, void>(
    (String deviceId, _) => DeviceBloc(
      deviceId: deviceId,
      bleService: sl<IBleService>(),
      logService: sl<LogService>(),
      deviceRepo: sl<DeviceRepository>(),
    ),
  );

  sl.registerFactoryParam<GattBloc, String, void>(
    (String deviceId, _) => GattBloc(
      deviceId: deviceId,
      bleService: sl<IBleService>(),
      logService: sl<LogService>(),
    ),
  );

  sl.registerFactory<LogBloc>(
    () => LogBloc(logService: sl<LogService>()),
  );

  sl.registerFactory<SettingsBloc>(
    () => SettingsBloc(settingsRepo: sl<SettingsRepository>()),
  );

  sl.registerFactory<DfuBloc>(
    () => DfuBloc(
      dfuManager: sl<DfuManager>(),
      logService: sl<LogService>(),
    ),
  );
}
