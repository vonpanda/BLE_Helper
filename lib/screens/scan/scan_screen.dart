import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/scan/scan_bloc.dart';
import '../../bloc/scan/scan_event.dart';
import '../../bloc/scan/scan_state.dart';
import '../../data/models/scan_filter.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/loading_indicator.dart';
import 'widgets/device_list_tile.dart';
import 'widgets/scan_filter_dialog.dart';

/// Main scan screen — displays discovered BLE devices.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  @override
  void initState() {
    super.initState();
    // Start scanning automatically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScanBloc>().add(const ScanStarted());
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Helper'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onPressed: () => _showFilterDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.description_outlined),
            tooltip: 'Logs',
            onPressed: () => context.pushNamed('log'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.pushNamed('settings'),
          ),
        ],
      ),
      body: BlocBuilder<ScanBloc, ScanState>(
        builder: (BuildContext context, ScanState state) {
          if (state.status == ScanStatus.error && state.devices.isEmpty) {
            return ErrorState(
              message: state.errorMessage ?? 'Scan error',
              retryLabel: 'Retry',
              onRetry: () {
                context.read<ScanBloc>().add(const ScanStarted());
              },
            );
          }

          if (!state.isScanning && state.devices.isEmpty) {
            return EmptyState(
              icon: Icons.bluetooth_searching,
              title: 'No devices found',
              subtitle:
                  'Press the scan button to start searching for BLE devices.',
              actionLabel: 'Start Scan',
              onAction: () {
                context.read<ScanBloc>().add(const ScanStarted());
              },
            );
          }

          if (state.devices.isEmpty && state.isScanning) {
            return const LoadingIndicator(message: 'Scanning for devices...');
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ScanBloc>().add(const ScanStarted());
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.devices.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (BuildContext context, int index) {
                return DeviceListTile(
                  device: state.devices[index],
                  onTap: () {
                    context.read<ScanBloc>().add(const ScanStopped());
                    context.pushNamed(
                      'deviceDetail',
                      pathParameters: {
                        'deviceId': state.devices[index].id,
                      },
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: BlocBuilder<ScanBloc, ScanState>(
        builder: (BuildContext context, ScanState state) {
          return FloatingActionButton.extended(
            onPressed: () {
              if (state.isScanning) {
                context.read<ScanBloc>().add(const ScanStopped());
              } else {
                context.read<ScanBloc>().add(ScanStarted(
                      filter: state.filter,
                    ));
              }
            },
            icon: Icon(state.isScanning ? Icons.stop : Icons.play_arrow),
            label: Text(state.isScanning ? 'Stop' : 'Scan'),
            backgroundColor: state.isScanning
                ? theme.colorScheme.errorContainer
                : theme.colorScheme.primaryContainer,
          );
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog<ScanFilter>(
      context: context,
      builder: (_) => BlocProvider<ScanBloc>.value(
        value: context.read<ScanBloc>(),
        child: const ScanFilterDialog(),
      ),
    ).then((ScanFilter? filter) {
      if (!context.mounted) {
        return;
      }
      if (filter != null) {
        context.read<ScanBloc>().add(FilterChanged(filter: filter));
      }
    });
  }
}
