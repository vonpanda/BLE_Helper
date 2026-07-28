import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/ble_service.dart';
import '../../../data/models/ble_characteristic.dart';
import '../../../core/utils/ble_utils.dart';

/// A recursive tree widget displaying GATT services and their characteristics.
class GattServiceTree extends StatelessWidget {
  final List<BleServiceInfo> services;
  final String deviceId;

  const GattServiceTree({
    super.key,
    required this.services,
    required this.deviceId,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (services.isEmpty) {
      return const Center(child: Text('No services discovered'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: services.length,
      itemBuilder: (BuildContext context, int index) {
        final BleServiceInfo service = services[index];
        final String shortUuid = BleUtils.shortenUuid(service.uuid);

        return ExpansionTile(
          leading: Icon(
            Icons.device_hub,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          title: Text(
            'Service: $shortUuid',
            style: theme.textTheme.titleSmall,
          ),
          subtitle: Text(
            service.uuid,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              fontSize: 10,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          children: service.characteristics.map(
            (BleCharacteristicInfo characteristic) {
              final String charShortUuid =
                  BleUtils.shortenUuid(characteristic.uuid);
              final List<String> propertyLabels =
                  characteristic.properties.labels;

              return ListTile(
                leading: Icon(
                  _getCharIcon(characteristic.properties),
                  color: theme.colorScheme.secondary,
                  size: 18,
                ),
                title: Text(
                  'Characteristic: $charShortUuid',
                  style: theme.textTheme.bodyMedium,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      characteristic.uuid,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: propertyLabels.map((String label) {
                        return Chip(
                          label: Text(
                            label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                            ),
                          ),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right, size: 18),
                onTap: () {
                  context.pushNamed(
                    'characteristic',
                    pathParameters: {
                      'deviceId': deviceId,
                      'serviceUuid': service.uuid,
                      'charUuid': characteristic.uuid,
                    },
                  );
                },
              );
            },
          ).toList(),
        );
      },
    );
  }

  IconData _getCharIcon(CharacteristicProperties props) {
    if (props.notify || props.indicate) {
      return Icons.notifications;
    }
    if (props.write || props.writeWithoutResponse) {
      return Icons.output;
    }
    if (props.read) {
      return Icons.input;
    }
    return Icons.device_unknown;
  }
}
