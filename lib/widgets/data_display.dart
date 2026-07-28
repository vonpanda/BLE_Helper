import 'package:flutter/material.dart';

import '../core/utils/data_formatter.dart';
import '../data/models/app_settings.dart';

/// Displays byte data in the selected format (Hex/ASCII/DEC/BIN).
class DataDisplay extends StatelessWidget {
  final List<int> data;
  final DataDisplayFormat format;
  final double? fontSize;
  final bool selectable;

  const DataDisplay({
    super.key,
    required this.data,
    this.format = DataDisplayFormat.HEX,
    this.fontSize,
    this.selectable = true,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    String displayText;
    switch (format) {
      case DataDisplayFormat.HEX:
        displayText = DataFormatter.toHexString(data);
        break;
      case DataDisplayFormat.ASCII:
        displayText = DataFormatter.toAsciiString(data);
        break;
      case DataDisplayFormat.DEC:
        displayText = DataFormatter.toDecString(data);
        break;
      case DataDisplayFormat.BIN:
        displayText = DataFormatter.toBinString(data);
        break;
    }

    final Widget textWidget = selectable
        ? SelectableText(
            displayText,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontSize: fontSize ?? 14,
              color: theme.colorScheme.onSurface,
            ),
          )
        : Text(
            displayText,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontSize: fontSize ?? 14,
              color: theme.colorScheme.onSurface,
            ),
          );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(100),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: textWidget,
    );
  }
}
