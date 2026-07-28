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
    // Connect to device and discover services
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeviceBloc>().add(
            ConnectRequested(deviceId: widget.deviceId),
          );
    });
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
          create: (_) => sl<DeviceBloc>(param1: widget.deviceId),
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
                  BlocBuilder<GattBloc, GattState>(
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

                  // RSSI tab
                  BlocBuilder<DeviceBloc, DeviceState>(
                    builder: (BuildContext context, DeviceState state) {
                      return RssiChart(rssi: state.rssi);
                    },
                  ),

                  // Info tab
                  BlocBuilder<DeviceBloc, DeviceState>(
                    builder: (BuildContext context, DeviceState state) {
                      return DeviceInfoCard(state: state);
                    },
                  ),

                  // Logs tab
                  DeviceLogList(deviceId: widget.deviceId),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
