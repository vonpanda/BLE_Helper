import 'package:flutter/material.dart';

import '../../../bloc/device/device_state.dart';
import '../../../core/constants/ui_constants.dart';

/// Card widget showing device connection information (MTU, params, status).
class DeviceInfoCard extends StatelessWidget {
  final DeviceState state;

  const DeviceInfoCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(UiConstants.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoTile(context, 'Device ID', state.deviceId),
          _buildInfoTile(
            context,
            'Connection',
            state.connectionState.name,
          ),
          _buildInfoTile(context, 'RSSI', '${state.rssi} dBm'),
          _buildInfoTile(context, 'MTU', '${state.mtu} bytes'),
          if (state.connectionParams != null) ...[
            const SizedBox(height: UiConstants.spacingMd),
            Text(
              'Connection Parameters',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: UiConstants.spacingSm),
            _buildInfoTile(
              context,
              'Interval',
              '${state.connectionParams!.intervalMs} ms',
            ),
            _buildInfoTile(
              context,
              'Latency',
              '${state.connectionParams!.latency}',
            ),
            _buildInfoTile(
              context,
              'Supervision Timeout',
              '${state.connectionParams!.supervisionTimeoutMs} ms',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, String label, String value) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
