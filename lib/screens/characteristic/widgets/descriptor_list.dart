import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/gatt/gatt_bloc.dart';
import '../../../bloc/gatt/gatt_event.dart';
import '../../../data/models/ble_descriptor.dart';
import '../../../core/utils/ble_utils.dart';
import '../../../core/constants/ui_constants.dart';

/// Displays the list of descriptors for a characteristic.
class DescriptorList extends StatelessWidget {
  final List<BleDescriptorInfo> descriptors;
  final String deviceId;
  final String serviceUuid;
  final String charUuid;

  const DescriptorList({
    super.key,
    required this.descriptors,
    required this.deviceId,
    required this.serviceUuid,
    required this.charUuid,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (descriptors.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UiConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Descriptors',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: UiConstants.spacingSm),
            ...descriptors.map((BleDescriptorInfo descriptor) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.description,
                  color: theme.colorScheme.tertiary,
                  size: 18,
                ),
                title: Text(
                  BleUtils.shortenUuid(descriptor.uuid),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                ),
                subtitle: Text(
                  descriptor.uuid,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.download, size: 18),
                  onPressed: () {
                    context.read<GattBloc>().add(
                          ReadDescriptor(
                            serviceUuid: serviceUuid,
                            charUuid: charUuid,
                            descUuid: descriptor.uuid,
                          ),
                        );
                  },
                  tooltip: 'Read Descriptor',
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
