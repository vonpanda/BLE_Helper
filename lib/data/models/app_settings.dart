import 'package:flutter/material.dart';

/// Data display format for characteristic values.
enum DataDisplayFormat {
  HEX,
  ASCII,
  DEC,
  BIN,
}

/// Application-wide user settings.
class AppSettings {
  final ThemeMode themeMode;
  final DataDisplayFormat defaultFormat;
  final int scanDurationSeconds;
  final bool autoReconnect;
  final int logRetentionDays;
  final bool enableAutoArchive;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.defaultFormat = DataDisplayFormat.HEX,
    this.scanDurationSeconds = 30,
    this.autoReconnect = false,
    this.logRetentionDays = 30,
    this.enableAutoArchive = true,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    DataDisplayFormat? defaultFormat,
    int? scanDurationSeconds,
    bool? autoReconnect,
    int? logRetentionDays,
    bool? enableAutoArchive,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      defaultFormat: defaultFormat ?? this.defaultFormat,
      scanDurationSeconds: scanDurationSeconds ?? this.scanDurationSeconds,
      autoReconnect: autoReconnect ?? this.autoReconnect,
      logRetentionDays: logRetentionDays ?? this.logRetentionDays,
      enableAutoArchive: enableAutoArchive ?? this.enableAutoArchive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.index,
      'defaultFormat': defaultFormat.name,
      'scanDurationSeconds': scanDurationSeconds,
      'autoReconnect': autoReconnect,
      'logRetentionDays': logRetentionDays,
      'enableAutoArchive': enableAutoArchive,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: ThemeMode.values[json['themeMode'] as int? ?? 0],
      defaultFormat: DataDisplayFormat.values.firstWhere(
        (e) => e.name == json['defaultFormat'],
        orElse: () => DataDisplayFormat.HEX,
      ),
      scanDurationSeconds: json['scanDurationSeconds'] as int? ?? 30,
      autoReconnect: json['autoReconnect'] as bool? ?? false,
      logRetentionDays: json['logRetentionDays'] as int? ?? 30,
      enableAutoArchive: json['enableAutoArchive'] as bool? ?? true,
    );
  }

  @override
  String toString() =>
      'AppSettings(theme: $themeMode, format: $defaultFormat, scan: ${scanDurationSeconds}s)';
}
