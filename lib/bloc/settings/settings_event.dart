import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../data/models/app_settings.dart';

/// Base class for all settings-related events.
sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Load settings from persistent storage.
class SettingsLoaded extends SettingsEvent {
  const SettingsLoaded();
}

/// Change the theme mode.
class ThemeChanged extends SettingsEvent {
  final ThemeMode mode;

  const ThemeChanged({required this.mode});

  @override
  List<Object?> get props => [mode];
}

/// Change the default data display format.
class FormatChanged extends SettingsEvent {
  final DataDisplayFormat format;

  const FormatChanged({required this.format});

  @override
  List<Object?> get props => [format];
}

/// Change the scan duration.
class ScanDurationChanged extends SettingsEvent {
  final int seconds;

  const ScanDurationChanged({required this.seconds});

  @override
  List<Object?> get props => [seconds];
}

/// Toggle auto-reconnect setting.
class AutoReconnectToggled extends SettingsEvent {
  final bool enabled;

  const AutoReconnectToggled({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

/// Change log retention period.
class LogRetentionChanged extends SettingsEvent {
  final int days;

  const LogRetentionChanged({required this.days});

  @override
  List<Object?> get props => [days];
}

/// Toggle auto archive setting.
class AutoArchiveToggled extends SettingsEvent {
  final bool enabled;

  const AutoArchiveToggled({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}
