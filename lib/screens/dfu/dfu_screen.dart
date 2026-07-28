import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/dfu/dfu_bloc.dart';
import '../../bloc/dfu/dfu_event.dart';
import '../../bloc/dfu/dfu_state.dart';
import '../../core/di/injection_container.dart';
import '../../core/constants/ui_constants.dart';
import '../../data/models/dfu_firmware.dart';
import 'widgets/firmware_picker.dart';
import 'widgets/dfu_progress.dart';

/// DFU firmware upgrade screen.
class DfuScreen extends StatelessWidget {
  const DfuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return BlocProvider<DfuBloc>(
      create: (_) => sl<DfuBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('DFU Firmware Upgrade'),
        ),
        body: BlocBuilder<DfuBloc, DfuState>(
          builder: (BuildContext context, DfuState state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(UiConstants.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(UiConstants.spacingMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.system_update,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: UiConstants.spacingSm),
                              Text(
                                'Firmware Upgrade',
                                style: theme.textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: UiConstants.spacingSm),
                          Text(
                            'Select a firmware file (.zip, .hex, or .bin) to upgrade your BLE device. '
                            'Firmware parsing is available; production DFU backend integration is required before upgrades are enabled.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: UiConstants.spacingMd),

                  // Firmware file picker
                  FirmwarePicker(
                    firmware: state.firmware,
                    onFilePicked: (DfuFirmware firmware) {
                      context
                          .read<DfuBloc>()
                          .add(FirmwareSelected(firmware: firmware));
                    },
                  ),

                  if (state.firmware != null) ...[
                    const SizedBox(height: UiConstants.spacingMd),

                    // Firmware info
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(UiConstants.spacingMd),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Firmware Info',
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: UiConstants.spacingSm),
                            _buildInfoRow(
                                context, 'File', state.firmware!.fileName),
                            _buildInfoRow(context, 'Size',
                                state.firmware!.fileSizeFormatted),
                            _buildInfoRow(context, 'Chip Type',
                                state.firmware!.chipType.name),
                            _buildInfoRow(context, 'Version',
                                state.firmware!.firmwareVersion),
                            _buildInfoRow(context, 'Valid',
                                state.firmware!.isValid ? 'Yes' : 'No'),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: UiConstants.spacingMd),

                    // DFU Progress
                    if (state.isInProgress ||
                        state.isCompleted ||
                        state.isFailed)
                      DfuProgress(state: state),

                    const SizedBox(height: UiConstants.spacingMd),

                    // Action buttons
                    if (state.isReady || state.isFailed)
                      FilledButton.tonalIcon(
                        onPressed: null,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('DFU Backend Not Configured'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),

                    if (state.isInProgress)
                      OutlinedButton.icon(
                        onPressed: () {
                          context.read<DfuBloc>().add(const DfuAborted());
                        },
                        icon: const Icon(Icons.stop),
                        label: const Text('Abort'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          foregroundColor: theme.colorScheme.error,
                        ),
                      ),
                  ],

                  // Error message
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: UiConstants.spacingMd),
                    Card(
                      color: theme.colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(UiConstants.spacingMd),
                        child: Text(
                          state.errorMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
