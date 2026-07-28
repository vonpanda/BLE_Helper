import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/gatt/gatt_bloc.dart';
import '../../../bloc/gatt/gatt_event.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../data/models/app_settings.dart';
import '../../../widgets/data_display.dart';

/// Notify/Indicate section with toggle and data stream display.
class NotifySection extends StatelessWidget {
  final String serviceUuid;
  final String charUuid;
  final bool isNotifying;
  final List<List<int>> notifyHistory;
  final DataDisplayFormat displayFormat;

  const NotifySection({
    super.key,
    required this.serviceUuid,
    required this.charUuid,
    required this.isNotifying,
    this.notifyHistory = const [],
    this.displayFormat = DataDisplayFormat.HEX,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UiConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isNotifying ? 'Notifications (Active)' : 'Notifications',
                  style: theme.textTheme.titleSmall,
                ),
                Switch(
                  value: isNotifying,
                  onChanged: (bool value) {
                    context.read<GattBloc>().add(
                          ToggleNotify(
                            serviceUuid: serviceUuid,
                            charUuid: charUuid,
                            enable: value,
                          ),
                        );
                  },
                ),
              ],
            ),
            const SizedBox(height: UiConstants.spacingSm),
            if (notifyHistory.isEmpty)
              Text(
                'No notifications received yet',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              ...notifyHistory.reversed.take(10).map((List<int> data) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: DataDisplay(
                    data: data,
                    format: displayFormat,
                    fontSize: 12,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
