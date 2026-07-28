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
            return _RefreshableScanBody(
              onRefresh: () => _restartScan(context),
              child: ErrorState(
                message: state.errorMessage ?? 'Scan error',
                retryLabel: 'Retry',
                onRetry: () {
                  context.read<ScanBloc>().add(ScanStarted(
                        filter: context.read<ScanBloc>().state.filter,
                      ));
                },
              ),
            );
          }

          if (!state.isScanning && state.devices.isEmpty) {
            return _RefreshableScanBody(
              onRefresh: () => _restartScan(context),
              child: const EmptyState(
                icon: Icons.bluetooth_searching,
                title: 'No devices found',
                subtitle: 'Pull down to scan again for nearby BLE devices.',
              ),
            );
          }

          if (state.devices.isEmpty && state.isScanning) {
            return _RefreshableScanBody(
              onRefresh: () => _restartScan(context),
              child: const LoadingIndicator(message: 'Scanning for devices...'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _restartScan(context),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.devices.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (BuildContext context, int index) {
                return DeviceListTile(
                  device: state.devices[index],
                  isNewSinceRefresh:
                      state.isHighlighted(state.devices[index].id),
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
    );
  }

  Future<void> _restartScan(BuildContext context) async {
    final ScanFilter filter = context.read<ScanBloc>().state.filter;
    context.read<ScanBloc>().add(ScanStarted(
          filter: filter,
          compareWithCurrentResults: true,
        ));
    await Future<void>.delayed(const Duration(milliseconds: 500));
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

class _RefreshableScanBody extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const _RefreshableScanBody({
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(child: child),
            ),
          );
        },
      ),
    );
  }
}
