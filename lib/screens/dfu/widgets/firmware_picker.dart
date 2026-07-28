import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/constants/ui_constants.dart';
import '../../../data/models/dfu_firmware.dart';
import '../../../services/dfu/dfu_firmware_parser.dart';

/// Widget for selecting a firmware file via system file picker or path input.
class FirmwarePicker extends StatelessWidget {
  final DfuFirmware? firmware;
  final ValueChanged<DfuFirmware>? onFilePicked;

  const FirmwarePicker({
    super.key,
    this.firmware,
    this.onFilePicked,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: () => _showPathInputDialog(context),
        borderRadius: BorderRadius.circular(UiConstants.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(UiConstants.spacingXl),
          child: Column(
            children: [
              Icon(
                firmware != null ? Icons.check_circle : Icons.upload_file,
                size: 48,
                color: firmware != null
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: UiConstants.spacingMd),
              Text(
                firmware != null
                    ? firmware!.fileName
                    : 'Tap to select firmware file',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: UiConstants.spacingSm),
              Text(
                'Supported: .zip (Nordic), .hex, .bin',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPathInputDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Enter Firmware Path'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '/path/to/firmware.zip',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final String path = controller.text.trim();
              if (path.isNotEmpty) {
                final File file = File(path);
                if (await file.exists()) {
                  final DfuFirmwareParser parser = DfuFirmwareParser();
                  final DfuFirmware firmware = await parser.parse(path);
                  onFilePicked?.call(firmware);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('File not found')),
                    );
                  }
                }
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
