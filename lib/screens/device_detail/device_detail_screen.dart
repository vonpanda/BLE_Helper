import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/device/device_bloc.dart';
import '../../bloc/device/device_event.dart';
import '../../bloc/device/device_state.dart';
import '../../bloc/gatt/gatt_bloc.dart';
import '../../bloc/gatt/gatt_event.dart';
import '../../bloc/gatt/gatt_state.dart';
import '../../core/di/injection_container.dart';
import '../../core/constants/ui_constants.dart';
import '../../services/ble/ble_service_interface.dart' as ble;
import '../../widgets/connection_status_badge.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import 'widgets/device_info_card.dart';
import 'widgets/gatt_service_tree.dart';
import 'widgets/rssi_chart.dart';
import 'widgets/device_log_list.dart';

/// Device detail screen — shows GATT services, RSSI chart, device info, and logs.
class DeviceDetailScreen extends StatefulWidget {
  final String deviceId;

  const DeviceDetailScreen({super.key, required this.deviceId});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DeviceBloc>(
          create: (_) => sl<DeviceBloc>(param1: widget.deviceId)
            ..add(ConnectRequested(deviceId: widget.deviceId)),
        ),
        BlocProvider<GattBloc>(
          create: (_) => sl<GattBloc>(param1: widget.deviceId),
        ),
      ],
      child: BlocBuilder<DeviceBloc, DeviceState>(
        builder: (BuildContext context, DeviceState deviceState) {
          return Scaffold(
            appBar: AppBar(
              title: Text(deviceState.deviceId),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  context.read<DeviceBloc>().add(const DisconnectRequested());
                  context.pop();
                },
              ),
              actions: [
                ConnectionStatusLabel(
                  isConnected: deviceState.isConnected,
                ),
                const SizedBox(width: UiConstants.spacingSm),
                if (deviceState.isConnected)
                  IconButton(
                    icon: const Icon(Icons.link_off),
                    tooltip: 'Disconnect',
                    onPressed: () {
                      context
                          .read<DeviceBloc>()
                          .add(const DisconnectRequested());
                    },
                  ),
              ],
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Services'),
                  Tab(text: 'RSSI'),
                  Tab(text: 'Info'),
                  Tab(text: 'Logs'),
                ],
              ),
            ),
            body: BlocListener<DeviceBloc, DeviceState>(
              listener: (BuildContext context, DeviceState state) {
                if (state.isConnected) {
                  context.read<GattBloc>().add(const DiscoverServices());
                }
              },
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Services tab
                  _DeviceTabPage(
                    connectionPanel: _ConnectionPanel(state: deviceState),
                    child: BlocBuilder<GattBloc, GattState>(
                      builder: (BuildContext context, GattState gattState) {
                        if (gattState.isLoadingServices) {
                          return const LoadingIndicator(
                              message: 'Discovering services...');
                        }
                        if (gattState.services.isEmpty) {
                          return const EmptyState(
                            icon: Icons.device_hub,
                            title: 'No Services',
                            subtitle:
                                'Connect to a device to discover GATT services.',
                          );
                        }
                        return GattServiceTree(
                          services: gattState.services,
                          deviceId: widget.deviceId,
                        );
                      },
                    ),
                  ),

                  // RSSI tab
                  _DeviceTabPage(
                    connectionPanel: _ConnectionPanel(state: deviceState),
                    child: BlocBuilder<DeviceBloc, DeviceState>(
                      builder: (BuildContext context, DeviceState state) {
                        return RssiChart(rssi: state.rssi);
                      },
                    ),
                  ),

                  // Info tab
                  _DeviceTabPage(
                    connectionPanel: _ConnectionPanel(state: deviceState),
                    child: BlocBuilder<DeviceBloc, DeviceState>(
                      builder: (BuildContext context, DeviceState state) {
                        return DeviceInfoCard(state: state);
                      },
                    ),
                  ),

                  // Logs tab
                  _DeviceTabPage(
                    connectionPanel: _ConnectionPanel(state: deviceState),
                    child: DeviceLogList(deviceId: widget.deviceId),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DeviceTabPage extends StatelessWidget {
  final Widget connectionPanel;
  final Widget child;

  const _DeviceTabPage({
    required this.connectionPanel,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        connectionPanel,
        Expanded(child: child),
      ],
    );
  }
}

class _ConnectionPanel extends StatelessWidget {
  final DeviceState state;

  const _ConnectionPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final _ConnectionPanelStyle style = _styleFor(theme);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(UiConstants.spacingMd),
      padding: const EdgeInsets.all(UiConstants.spacingMd),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(UiConstants.radiusMd),
        border: Border.all(color: style.border),
      ),
      child: Row(
        children: [
          if (state.connectionState == ble.ConnectionState.connecting)
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: style.foreground,
              ),
            )
          else
            Icon(style.icon, color: style.foreground),
          const SizedBox(width: UiConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  style.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: style.foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  state.errorMessage ?? style.subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: style.foreground.withValues(alpha: 0.84),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (state.isConnected) ...[
            const SizedBox(width: UiConstants.spacingMd),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${state.rssi} dBm',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: style.foreground,
                    fontFeatures: const [],
                  ),
                ),
                Text(
                  'MTU ${state.mtu}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: style.foreground.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  _ConnectionPanelStyle _styleFor(ThemeData theme) {
    switch (state.connectionState) {
      case ble.ConnectionState.connected:
        return _ConnectionPanelStyle(
          icon: Icons.bluetooth_connected,
          title: 'Connected',
          subtitle: 'GATT services are available below.',
          foreground: theme.colorScheme.onPrimaryContainer,
          background: theme.colorScheme.primaryContainer,
          border: theme.colorScheme.primary.withValues(alpha: 0.35),
        );
      case ble.ConnectionState.connecting:
        return _ConnectionPanelStyle(
          icon: Icons.bluetooth_searching,
          title: 'Connecting',
          subtitle: 'Opening BLE connection and preparing GATT discovery.',
          foreground: theme.colorScheme.onSecondaryContainer,
          background: theme.colorScheme.secondaryContainer,
          border: theme.colorScheme.secondary.withValues(alpha: 0.35),
        );
      case ble.ConnectionState.disconnecting:
        return _ConnectionPanelStyle(
          icon: Icons.link_off,
          title: 'Disconnecting',
          subtitle: 'Closing the active BLE connection.',
          foreground: theme.colorScheme.onTertiaryContainer,
          background: theme.colorScheme.tertiaryContainer,
          border: theme.colorScheme.tertiary.withValues(alpha: 0.35),
        );
      case ble.ConnectionState.disconnected:
        return _ConnectionPanelStyle(
          icon: Icons.bluetooth_disabled,
          title:
              state.errorMessage == null ? 'Disconnected' : 'Connection Failed',
          subtitle: 'Tap another device from the scanner to connect.',
          foreground: theme.colorScheme.onErrorContainer,
          background: theme.colorScheme.errorContainer,
          border: theme.colorScheme.error.withValues(alpha: 0.35),
        );
    }
  }
}

class _ConnectionPanelStyle {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color foreground;
  final Color background;
  final Color border;

  const _ConnectionPanelStyle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.foreground,
    required this.background,
    required this.border,
  });
}
