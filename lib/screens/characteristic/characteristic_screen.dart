import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/gatt/gatt_bloc.dart';
import '../../bloc/gatt/gatt_event.dart';
import '../../bloc/gatt/gatt_state.dart';
import '../../core/utils/ble_utils.dart';
import '../../core/constants/ui_constants.dart';
import '../../data/models/ble_characteristic.dart';
import '../../data/models/ble_service.dart';
import '../../data/models/app_settings.dart';
import '../../widgets/format_switcher.dart';
import '../../widgets/data_display.dart';
import '../../widgets/data_input.dart';
import 'widgets/notify_section.dart';
import 'widgets/descriptor_list.dart';

/// Characteristic interaction screen — read, write, notify, descriptors.
class CharacteristicScreen extends StatefulWidget {
  final String deviceId;
  final String serviceUuid;
  final String charUuid;

  const CharacteristicScreen({
    super.key,
    required this.deviceId,
    required this.serviceUuid,
    required this.charUuid,
  });

  @override
  State<CharacteristicScreen> createState() => _CharacteristicScreenState();
}

class _CharacteristicScreenState extends State<CharacteristicScreen> {
  BleCharacteristicInfo? _characteristic;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _findCharacteristic();
    });
  }

  void _findCharacteristic() {
    final GattState gattState = context.read<GattBloc>().state;
    for (final BleServiceInfo service in gattState.services) {
      if (service.uuid == widget.serviceUuid) {
        for (final BleCharacteristicInfo char in service.characteristics) {
          if (char.uuid == widget.charUuid) {
            setState(() {
              _characteristic = char;
            });
            return;
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String shortUuid = BleUtils.shortenUuid(widget.charUuid);

    return Scaffold(
      appBar: AppBar(
        title: Text('Characteristic: $shortUuid'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<GattBloc, GattState>(
        builder: (BuildContext context, GattState gattState) {
          if (_characteristic == null) {
            // Try to find it again
            _findCharacteristic();
            if (_characteristic == null) {
              return const Center(child: Text('Characteristic not found'));
            }
          }

          final BleCharacteristicInfo char = _characteristic!;
          final String key = GattState.charKey(
            widget.serviceUuid,
            widget.charUuid,
          );
          final CharacteristicState? charState =
              gattState.characteristicStates[key];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(UiConstants.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // UUID and properties
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(UiConstants.spacingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'UUID',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SelectableText(
                          widget.charUuid,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: UiConstants.spacingSm),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: char.properties.labels.map((String label) {
                            return Chip(
                              label: Text(label,
                                  style: theme.textTheme.labelSmall),
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: UiConstants.spacingMd),

                // Format switcher
                FormatSwitcher(
                  selectedFormat: gattState.displayFormat,
                  onFormatChanged: (DataDisplayFormat format) {
                    // Format is handled per-view, not at BLoC level
                    setState(() {});
                  },
                ),

                const SizedBox(height: UiConstants.spacingMd),

                // Read section — always visible
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(UiConstants.spacingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Read',
                              style: theme.textTheme.titleSmall,
                            ),
                            FilledButton.tonal(
                              onPressed: char.properties.read &&
                                      !(charState?.isReading ?? false)
                                  ? () {
                                      context.read<GattBloc>().add(
                                            ReadCharacteristic(
                                              serviceUuid: widget.serviceUuid,
                                              charUuid: widget.charUuid,
                                            ),
                                          );
                                    }
                                  : null,
                              child: charState?.isReading == true
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Text('Read'),
                            ),
                          ],
                        ),
                        const SizedBox(height: UiConstants.spacingSm),
                        if (charState?.value != null)
                          DataDisplay(
                            data: charState!.value!,
                            format: gattState.displayFormat,
                          )
                        else
                          Text(
                            'Tap Read to fetch value',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: UiConstants.spacingMd),

                // Write section — visible when write is supported
                if (char.properties.canWrite)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(UiConstants.spacingMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Write',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: UiConstants.spacingSm),
                          DataInput(
                            onSend: (List<int> data) {
                              context.read<GattBloc>().add(
                                    WriteCharacteristic(
                                      serviceUuid: widget.serviceUuid,
                                      charUuid: widget.charUuid,
                                      data: data,
                                      withResponse: char.properties.write,
                                    ),
                                  );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: UiConstants.spacingMd),

                // Notify section
                if (char.properties.notify || char.properties.indicate)
                  NotifySection(
                    serviceUuid: widget.serviceUuid,
                    charUuid: widget.charUuid,
                    isNotifying: charState?.isNotifying ?? false,
                    notifyHistory: charState?.notifyHistory ?? [],
                    displayFormat: gattState.displayFormat,
                  ),

                const SizedBox(height: UiConstants.spacingMd),

                // Descriptors section
                if (char.descriptors.isNotEmpty)
                  DescriptorList(
                    descriptors: char.descriptors,
                    deviceId: widget.deviceId,
                    serviceUuid: widget.serviceUuid,
                    charUuid: widget.charUuid,
                  ),

                // Error display
                if (gattState.errorMessage != null)
                  Card(
                    color: theme.colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(UiConstants.spacingMd),
                      child: Text(
                        gattState.errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
