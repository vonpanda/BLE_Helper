import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../screens/scan/scan_screen.dart';
import '../../screens/device_detail/device_detail_screen.dart';
import '../../screens/characteristic/characteristic_screen.dart';
import '../../screens/log/log_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/dfu/dfu_screen.dart';

/// Named route constants used throughout the app.
class AppRoutes {
  AppRoutes._();

  static const String scan = 'scan';
  static const String deviceDetail = 'deviceDetail';
  static const String characteristic = 'characteristic';
  static const String log = 'log';
  static const String settings = 'settings';
  static const String dfu = 'dfu';

  // --- Route Paths ---
  static const String scanPath = '/';
  static const String deviceDetailPath = '/device/:deviceId';
  static const String characteristicPath =
      '/device/:deviceId/service/:serviceUuid/characteristic/:charUuid';
  static const String logPath = '/log';
  static const String settingsPath = '/settings';
  static const String dfuPath = '/dfu';
}

/// Build a [GoRouter] instance with all application routes.
GoRouter buildAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.scanPath,
    routes: [
      GoRoute(
        path: AppRoutes.scanPath,
        name: AppRoutes.scan,
        builder: (BuildContext context, GoRouterState state) {
          return const ScanScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.deviceDetailPath,
        name: AppRoutes.deviceDetail,
        builder: (BuildContext context, GoRouterState state) {
          final String deviceId = state.pathParameters['deviceId']!;
          return DeviceDetailScreen(deviceId: deviceId);
        },
      ),
      GoRoute(
        path: AppRoutes.characteristicPath,
        name: AppRoutes.characteristic,
        builder: (BuildContext context, GoRouterState state) {
          final String deviceId = state.pathParameters['deviceId']!;
          final String serviceUuid = state.pathParameters['serviceUuid']!;
          final String charUuid = state.pathParameters['charUuid']!;
          return CharacteristicScreen(
            deviceId: deviceId,
            serviceUuid: serviceUuid,
            charUuid: charUuid,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.logPath,
        name: AppRoutes.log,
        builder: (BuildContext context, GoRouterState state) {
          return const LogScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.settingsPath,
        name: AppRoutes.settings,
        builder: (BuildContext context, GoRouterState state) {
          return const SettingsScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.dfuPath,
        name: AppRoutes.dfu,
        builder: (BuildContext context, GoRouterState state) {
          return const DfuScreen();
        },
      ),
    ],
  );
}
