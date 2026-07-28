import 'package:flutter/material.dart';

import '../data/models/app_settings.dart';

/// A button group to switch between data display formats (Hex/ASCII/DEC/BIN).
class FormatSwitcher extends StatelessWidget {
  final DataDisplayFormat selectedFormat;
  final ValueChanged<DataDisplayFormat> onFormatChanged;

  const FormatSwitcher({
    super.key,
    required this.selectedFormat,
    required this.onFormatChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SegmentedButton<DataDisplayFormat>(
      segments: DataDisplayFormat.values.map((DataDisplayFormat format) {
        return ButtonSegment<DataDisplayFormat>(
          value: format,
          label: Text(
            format.name,
            style: theme.textTheme.labelSmall,
          ),
        );
      }).toList(),
      selected: {selectedFormat},
      onSelectionChanged: (Set<DataDisplayFormat> selection) {
        onFormatChanged(selection.first);
      },
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
