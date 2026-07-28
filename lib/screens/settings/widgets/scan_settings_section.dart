import 'package:flutter/material.dart';

import '../../../core/constants/ui_constants.dart';

/// Section for configuring scan duration and related options.
class ScanSettingsSection extends StatelessWidget {
  final int scanDuration;
  final ValueChanged<int> onDurationChanged;

  const ScanSettingsSection({
    super.key,
    required this.scanDuration,
    required this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    const List<int> options = [10, 30, 60, 0]; // 0 = infinite

    return Column(
      children: [
        ListTile(
          title: const Text('Scan Duration'),
          subtitle: Text(
              scanDuration == 0 ? 'Never auto-stop' : '$scanDuration seconds'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: UiConstants.spacingMd,
          ),
          child: Wrap(
            spacing: UiConstants.spacingSm,
            children: options.map((int duration) {
              final bool selected = scanDuration == duration;
              return ChoiceChip(
                label: Text(
                  duration == 0 ? 'Infinite' : '${duration}s',
                ),
                selected: selected,
                onSelected: (_) => onDurationChanged(duration),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
