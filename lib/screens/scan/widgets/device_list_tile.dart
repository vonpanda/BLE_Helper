import 'package:flutter/material.dart';

import '../../../data/models/ble_device.dart';
import '../../../core/utils/ble_utils.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/ui_constants.dart';
import 'rssi_indicator.dart';

/// A list tile displaying a BLE device's name, MAC, RSSI, and status.
class DeviceListTile extends StatelessWidget {
  final BleDevice device;
  final bool isNewSinceRefresh;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const DeviceListTile({
    super.key,
    required this.device,
    this.isNewSinceRefresh = false,
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final String macDisplay = BleUtils.formatMacAddress(device.macAddress);
    final String rssiLabel = BleUtils.rssiToLabel(device.rssi);

    Color rssiColor;
    switch (rssiLabel) {
      case 'Excellent':
        rssiColor = AppColors.rssiExcellent;
        break;
      case 'Good':
        rssiColor = AppColors.rssiGood;
        break;
      case 'Fair':
        rssiColor = AppColors.rssiFair;
        break;
      default:
        rssiColor = AppColors.rssiPoor;
    }

    return ListTile(
      tileColor: isNewSinceRefresh
          ? Colors.amber.withValues(alpha: 0.16)
          : Colors.transparent,
      leading: CircleAvatar(
        backgroundColor: isNewSinceRefresh
            ? Colors.amber.shade200
            : theme.colorScheme.primaryContainer,
        child: device.isConnected
            ? const Icon(
                Icons.bluetooth_connected,
                color: AppColors.bleConnected,
                size: 20,
              )
            : Icon(
                isNewSinceRefresh ? Icons.new_releases : Icons.bluetooth,
                color: isNewSinceRefresh
                    ? Colors.amber.shade900
                    : theme.colorScheme.onPrimaryContainer,
                size: 20,
              ),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              device.name,
              style: theme.textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (device.isFavorite)
            const Icon(
              Icons.star,
              size: 16,
              color: Colors.amber,
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(
            macDisplay,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              RssiIndicator(rssi: device.rssi, size: 14),
              const SizedBox(width: UiConstants.spacingSm),
              Text(
                '${device.rssi} dBm · $rssiLabel',
                style: theme.textTheme.bodySmall?.copyWith(color: rssiColor),
              ),
            ],
          ),
        ],
      ),
      trailing: device.isConnected
          ? Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant)
          : isNewSinceRefresh
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UiConstants.spacingSm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade200,
                    borderRadius: BorderRadius.circular(UiConstants.radiusSm),
                  ),
                  child: Text(
                    'New',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : null,
      onTap: onTap,
    );
  }
}
