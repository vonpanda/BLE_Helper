import 'package:flutter/material.dart';

import '../../../core/constants/ui_constants.dart';
import '../../../widgets/data_input.dart';

/// Write section with data input and send button.
class WriteSection extends StatelessWidget {
  final bool canWrite;
  final bool withResponse;
  final bool isWriting;
  final ValueChanged<bool>? onWithResponseChanged;
  final Function(List<int> data)? onSend;

  const WriteSection({
    super.key,
    this.canWrite = false,
    this.withResponse = true,
    this.isWriting = false,
    this.onWithResponseChanged,
    this.onSend,
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
            Text('Write', style: theme.textTheme.titleSmall),
            const SizedBox(height: UiConstants.spacingSm),

            // Write type toggle
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: true,
                        label: Text('With Response'),
                      ),
                      ButtonSegment(
                        value: false,
                        label: Text('No Response'),
                      ),
                    ],
                    selected: {withResponse},
                    onSelectionChanged: (Set<bool> selection) {
                      onWithResponseChanged?.call(selection.first);
                    },
                    style: SegmentedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: UiConstants.spacingSm),

            // Data input
            DataInput(
              enabled: canWrite && !isWriting,
              onSend: onSend,
            ),
          ],
        ),
      ),
    );
  }
}
