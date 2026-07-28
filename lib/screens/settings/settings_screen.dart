import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/settings/settings_bloc.dart';
import '../../bloc/settings/settings_event.dart';
import '../../bloc/settings/settings_state.dart';
import '../../core/di/injection_container.dart';
import '../../core/constants/ui_constants.dart';
import '../../data/models/app_settings.dart';
import 'widgets/scan_settings_section.dart';
import 'widgets/theme_selector.dart';

/// Settings screen — manages app preferences (theme, format, scan duration, etc.).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsBloc>(
      create: (_) => sl<SettingsBloc>()..add(const SettingsLoaded()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (BuildContext context, SettingsState state) {
            if (!state.isLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              padding: const EdgeInsets.symmetric(
                vertical: UiConstants.spacingMd,
              ),
              children: [
                // Theme
                _buildSectionHeader(context, 'Appearance'),
                ThemeSelector(
                  currentMode: state.settings.themeMode,
                  onChanged: (ThemeMode mode) {
                    context.read<SettingsBloc>().add(ThemeChanged(mode: mode));
                  },
                ),

                const Divider(),

                // Data format
                _buildSectionHeader(context, 'Data Display'),
                _buildFormatSelector(context, state),
                const Divider(),

                // Scan settings
                _buildSectionHeader(context, 'Scan'),
                ScanSettingsSection(
                  scanDuration: state.settings.scanDurationSeconds,
                  onDurationChanged: (int seconds) {
                    context
                        .read<SettingsBloc>()
                        .add(ScanDurationChanged(seconds: seconds));
                  },
                ),
                const Divider(),

                // Log settings
                _buildSectionHeader(context, 'Logs'),
                SwitchListTile(
                  title: const Text('Auto Archive'),
                  subtitle: const Text(
                      'Automatically archive logs when limits are exceeded'),
                  value: state.settings.enableAutoArchive,
                  onChanged: (bool value) {
                    context
                        .read<SettingsBloc>()
                        .add(AutoArchiveToggled(enabled: value));
                  },
                ),
                ListTile(
                  title: const Text('Log Retention'),
                  subtitle: Text('${state.settings.logRetentionDays} days'),
                  trailing: DropdownButton<int>(
                    value: state.settings.logRetentionDays,
                    items: [7, 14, 30, 60, 90].map((int days) {
                      return DropdownMenuItem<int>(
                        value: days,
                        child: Text('$days days'),
                      );
                    }).toList(),
                    onChanged: (int? value) {
                      if (value != null) {
                        context
                            .read<SettingsBloc>()
                            .add(LogRetentionChanged(days: value));
                      }
                    },
                  ),
                ),
                const Divider(),

                // Connection
                _buildSectionHeader(context, 'Connection'),
                SwitchListTile(
                  title: const Text('Auto Reconnect'),
                  subtitle: const Text(
                      'Automatically reconnect to previously paired devices'),
                  value: state.settings.autoReconnect,
                  onChanged: (bool value) {
                    context
                        .read<SettingsBloc>()
                        .add(AutoReconnectToggled(enabled: value));
                  },
                ),
                const Divider(),

                // DFU entry
                _buildSectionHeader(context, 'Firmware Update'),
                ListTile(
                  leading: const Icon(Icons.system_update),
                  title: const Text('DFU Firmware Upgrade'),
                  subtitle: const Text('Update firmware on connected devices'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.pushNamed('dfu'),
                ),

                // About
                const Divider(),
                _buildSectionHeader(context, 'About'),
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('BLE Helper'),
                  subtitle: Text('Version 1.0.0'),
                ),

                const SizedBox(height: UiConstants.spacingXxl),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UiConstants.spacingMd,
        UiConstants.spacingSm,
        UiConstants.spacingMd,
        UiConstants.spacingSm,
      ),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFormatSelector(BuildContext context, SettingsState state) {
    return ListTile(
      title: const Text('Default Format'),
      subtitle: Text(state.settings.defaultFormat.name),
      trailing: DropdownButton<DataDisplayFormat>(
        value: state.settings.defaultFormat,
        items: DataDisplayFormat.values.map((DataDisplayFormat f) {
          return DropdownMenuItem<DataDisplayFormat>(
            value: f,
            child: Text(f.name),
          );
        }).toList(),
        onChanged: (DataDisplayFormat? value) {
          if (value != null) {
            context.read<SettingsBloc>().add(FormatChanged(format: value));
          }
        },
      ),
    );
  }
}
