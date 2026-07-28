import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'bloc/settings/settings_bloc.dart';
import 'bloc/settings/settings_event.dart';
import 'bloc/settings/settings_state.dart';
import 'bloc/scan/scan_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await configureDependencies();

  runApp(const BleHelperApp());
}

/// Root application widget.
class BleHelperApp extends StatelessWidget {
  const BleHelperApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = buildAppRouter();

    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsBloc>(
          create: (_) => sl<SettingsBloc>()..add(const SettingsLoaded()),
        ),
        BlocProvider<ScanBloc>(
          create: (_) => sl<ScanBloc>(),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (BuildContext context, SettingsState settingsState) {
          return MaterialApp.router(
            title: 'BLE Helper',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsState.isLoaded
                ? settingsState.settings.themeMode
                : ThemeMode.system,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
