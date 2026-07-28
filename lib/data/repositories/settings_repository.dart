import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

/// Repository for persisting and retrieving user settings via SharedPreferences.
class SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepository({required SharedPreferences prefs}) : _prefs = prefs;

  // --- Keys ---
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyDefaultFormat = 'default_format';
  static const String _keyScanDuration = 'scan_duration_seconds';
  static const String _keyAutoReconnect = 'auto_reconnect';
  static const String _keyLogRetention = 'log_retention_days';
  static const String _keyEnableAutoArchive = 'enable_auto_archive';

  /// Load the full [AppSettings] from persistent storage.
  AppSettings getSettings() {
    return AppSettings(
      themeMode: ThemeMode.values[_prefs.getInt(_keyThemeMode) ?? 0],
      defaultFormat: DataDisplayFormat.values.firstWhere(
        (e) => e.name == _prefs.getString(_keyDefaultFormat),
        orElse: () => DataDisplayFormat.HEX,
      ),
      scanDurationSeconds: _prefs.getInt(_keyScanDuration) ?? 30,
      autoReconnect: _prefs.getBool(_keyAutoReconnect) ?? false,
      logRetentionDays: _prefs.getInt(_keyLogRetention) ?? 30,
      enableAutoArchive: _prefs.getBool(_keyEnableAutoArchive) ?? true,
    );
  }

  /// Save the full [AppSettings] to persistent storage.
  Future<void> saveSettings(AppSettings settings) async {
    await _prefs.setInt(_keyThemeMode, settings.themeMode.index);
    await _prefs.setString(_keyDefaultFormat, settings.defaultFormat.name);
    await _prefs.setInt(_keyScanDuration, settings.scanDurationSeconds);
    await _prefs.setBool(_keyAutoReconnect, settings.autoReconnect);
    await _prefs.setInt(_keyLogRetention, settings.logRetentionDays);
    await _prefs.setBool(_keyEnableAutoArchive, settings.enableAutoArchive);
  }

  /// Get current theme mode.
  ThemeMode getThemeMode() {
    return ThemeMode.values[_prefs.getInt(_keyThemeMode) ?? 0];
  }

  /// Set theme mode.
  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setInt(_keyThemeMode, mode.index);
  }

  /// Get the default data display format.
  DataDisplayFormat getDefaultFormat() {
    return DataDisplayFormat.values.firstWhere(
      (e) => e.name == _prefs.getString(_keyDefaultFormat),
      orElse: () => DataDisplayFormat.HEX,
    );
  }

  /// Set the default data display format.
  Future<void> setDefaultFormat(DataDisplayFormat format) async {
    await _prefs.setString(_keyDefaultFormat, format.name);
  }
}
