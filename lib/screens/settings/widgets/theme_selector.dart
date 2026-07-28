import 'package:flutter/material.dart';

/// A widget for selecting the app theme mode (light/dark/system).
class ThemeSelector extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onChanged;

  const ThemeSelector({
    super.key,
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListTile(
      title: const Text('Theme'),
      subtitle: Text(_themeModeLabel(currentMode)),
      leading: Icon(_themeModeIcon(currentMode)),
      trailing: SegmentedButton<ThemeMode>(
        segments: ThemeMode.values.map((ThemeMode mode) {
          return ButtonSegment<ThemeMode>(
            value: mode,
            label: Text(
              _themeModeShortLabel(mode),
              style: theme.textTheme.labelSmall,
            ),
            icon: Icon(
              _themeModeIcon(mode),
              size: 16,
            ),
          );
        }).toList(),
        selected: {currentMode},
        onSelectionChanged: (Set<ThemeMode> selection) {
          onChanged(selection.first);
        },
        style: SegmentedButton.styleFrom(
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  String _themeModeShortLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'Auto';
    }
  }

  IconData _themeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.settings_suggest;
    }
  }
}
