import 'package:flutter/material.dart';

import '../../../data/models/log_entry.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../core/extensions/datetime_extension.dart';

/// A compact tile showing a single log entry with event type icon, timestamp, and summary.
class LogEntryTile extends StatelessWidget {
  final LogEntry entry;

  const LogEntryTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListTile(
      dense: true,
      leading: _buildEventIcon(entry.eventType),
      title: Text(
        entry.description,
        style: theme.textTheme.bodySmall,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Text(
            entry.timestamp.toLogTime,
            style: theme.textTheme.labelSmall?.copyWith(
              fontFamily: 'monospace',
              fontSize: 10,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (entry.deviceName != null) ...[
            const SizedBox(width: UiConstants.spacingSm),
            Flexible(
              child: Text(
                entry.deviceName!,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
      trailing: _buildDirectionBadge(context, entry),
    );
  }

  Widget _buildEventIcon(LogEventType type) {
    switch (type) {
      case LogEventType.SCAN_DEVICE_FOUND:
        return const Icon(Icons.bluetooth_searching,
            size: 18, color: AppColors.primary);
      case LogEventType.DEVICE_CONNECTED:
        return const Icon(Icons.bluetooth_connected,
            size: 18, color: AppColors.bleConnected);
      case LogEventType.DEVICE_DISCONNECTED:
        return const Icon(Icons.bluetooth_disabled,
            size: 18, color: AppColors.bleDisconnected);
      case LogEventType.GATT_READ:
        return const Icon(Icons.input, size: 18, color: AppColors.directionRx);
      case LogEventType.GATT_WRITE:
        return const Icon(Icons.output, size: 18, color: AppColors.directionTx);
      case LogEventType.GATT_NOTIFY:
      case LogEventType.GATT_INDICATE:
        return const Icon(Icons.notifications,
            size: 18, color: AppColors.secondary);
      case LogEventType.MTU_CHANGED:
        return const Icon(Icons.swap_vert, size: 18, color: AppColors.tertiary);
      case LogEventType.ERROR:
        return const Icon(Icons.error, size: 18, color: AppColors.error);
      case LogEventType.DFU_STARTED:
      case LogEventType.DFU_PROGRESS:
      case LogEventType.DFU_COMPLETED:
        return const Icon(Icons.system_update,
            size: 18, color: AppColors.dfuProgress);
    }
  }

  Widget _buildDirectionBadge(BuildContext context, LogEntry entry) {
    final ThemeData theme = Theme.of(context);
    if (entry.direction == null) return const SizedBox.shrink();

    final Color color = entry.direction == LogDirection.TX
        ? AppColors.directionTx
        : AppColors.directionRx;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        entry.direction!.name,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
