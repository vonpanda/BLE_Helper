import 'package:flutter/material.dart';

import '../../../core/constants/ui_constants.dart';

/// Displays a read section with value and read button.
class ReadSection extends StatelessWidget {
  final bool canRead;
  final bool isReading;
  final List<int>? value;
  final VoidCallback? onRead;
  final Widget? dataDisplay;

  const ReadSection({
    super.key,
    this.canRead = false,
    this.isReading = false,
    this.value,
    this.onRead,
    this.dataDisplay,
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
                Text('Read', style: theme.textTheme.titleSmall),
                FilledButton.tonal(
                  onPressed: canRead && !isReading ? onRead : null,
                  child: isReading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Read'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            dataDisplay ??
                Text(
                  'Not read yet',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
