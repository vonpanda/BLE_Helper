import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/constants/ui_constants.dart';

/// A small badge/chip showing the BLE connection status.
class ConnectionStatusBadge extends StatelessWidget {
  final bool isConnected;
  final double size;

  const ConnectionStatusBadge({
    super.key,
    required this.isConnected,
    this.size = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isConnected ? AppColors.bleConnected : AppColors.bleDisconnected,
        boxShadow: [
          BoxShadow(
            color: (isConnected
                    ? AppColors.bleConnected
                    : AppColors.bleDisconnected)
                .withAlpha(100),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

/// Extended connection status badge with text label.
class ConnectionStatusLabel extends StatelessWidget {
  final bool isConnected;
  final String? connectedText;
  final String? disconnectedText;

  const ConnectionStatusLabel({
    super.key,
    required this.isConnected,
    this.connectedText,
    this.disconnectedText,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConnectionStatusBadge(isConnected: isConnected),
        const SizedBox(width: UiConstants.spacingSm),
        Text(
          isConnected
              ? (connectedText ?? 'Connected')
              : (disconnectedText ?? 'Disconnected'),
          style: theme.textTheme.labelMedium?.copyWith(
            color: isConnected
                ? AppColors.bleConnected
                : AppColors.bleDisconnected,
          ),
        ),
      ],
    );
  }
}
