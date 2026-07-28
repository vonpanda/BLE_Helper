import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ble_helper/data/models/app_settings.dart';

void main() {
  group('AppSettings', () {
    group('Constructor & Defaults', () {
      test('should have correct default values', () {
        const settings = AppSettings();
        expect(settings.themeMode, ThemeMode.system);
        expect(settings.defaultFormat, DataDisplayFormat.HEX);
        expect(settings.scanDurationSeconds, 30);
        expect(settings.autoReconnect, false);
        expect(settings.logRetentionDays, 30);
        expect(settings.enableAutoArchive, true);
      });

      test('should create with custom values', () {
        const settings = AppSettings(
          themeMode: ThemeMode.dark,
          defaultFormat: DataDisplayFormat.ASCII,
          scanDurationSeconds: 60,
          autoReconnect: true,
          logRetentionDays: 90,
          enableAutoArchive: false,
        );
        expect(settings.themeMode, ThemeMode.dark);
        expect(settings.defaultFormat, DataDisplayFormat.ASCII);
        expect(settings.scanDurationSeconds, 60);
        expect(settings.autoReconnect, true);
        expect(settings.logRetentionDays, 90);
        expect(settings.enableAutoArchive, false);
      });
    });

    group('copyWith', () {
      test('should copy with new values', () {
        const settings = AppSettings();
        final copied = settings.copyWith(
          themeMode: ThemeMode.light,
          scanDurationSeconds: 45,
        );
        expect(copied.themeMode, ThemeMode.light);
        expect(copied.scanDurationSeconds, 45);
        expect(copied.defaultFormat, DataDisplayFormat.HEX); // unchanged
        expect(copied.autoReconnect, false); // unchanged
      });

      test('should copy with no changes', () {
        const settings = AppSettings(
          themeMode: ThemeMode.dark,
          scanDurationSeconds: 60,
        );
        final copied = settings.copyWith();
        expect(copied.themeMode, ThemeMode.dark);
        expect(copied.scanDurationSeconds, 60);
      });
    });

    group('toJson', () {
      test('should serialize themeMode as index', () {
        const settings = AppSettings(themeMode: ThemeMode.dark);
        final json = settings.toJson();
        expect(json['themeMode'], ThemeMode.dark.index);
      });

      test('should serialize defaultFormat as name string', () {
        const settings = AppSettings(defaultFormat: DataDisplayFormat.BIN);
        final json = settings.toJson();
        expect(json['defaultFormat'], 'BIN');
      });

      test('should serialize all fields', () {
        const settings = AppSettings(
          themeMode: ThemeMode.light,
          defaultFormat: DataDisplayFormat.DEC,
          scanDurationSeconds: 20,
          autoReconnect: true,
          logRetentionDays: 60,
          enableAutoArchive: false,
        );
        final json = settings.toJson();
        expect(json['themeMode'], ThemeMode.light.index);
        expect(json['defaultFormat'], 'DEC');
        expect(json['scanDurationSeconds'], 20);
        expect(json['autoReconnect'], true);
        expect(json['logRetentionDays'], 60);
        expect(json['enableAutoArchive'], false);
      });
    });

    group('fromJson', () {
      test('should deserialize themeMode from index', () {
        final json = {'themeMode': ThemeMode.dark.index};
        final parsed = AppSettings.fromJson(json);
        expect(parsed.themeMode, ThemeMode.dark);
      });

      test('should deserialize defaultFormat from name', () {
        final json = {'defaultFormat': 'ASCII'};
        final parsed = AppSettings.fromJson(json);
        expect(parsed.defaultFormat, DataDisplayFormat.ASCII);
      });

      test('should handle unknown format with orElse', () {
        final json = {'defaultFormat': 'INVALID'};
        final parsed = AppSettings.fromJson(json);
        expect(parsed.defaultFormat, DataDisplayFormat.HEX);
      });

      test('should handle missing fields with defaults', () {
        final parsed = AppSettings.fromJson({});
        expect(parsed.themeMode, ThemeMode.system);
        expect(parsed.defaultFormat, DataDisplayFormat.HEX);
        expect(parsed.scanDurationSeconds, 30);
        expect(parsed.autoReconnect, false);
        expect(parsed.logRetentionDays, 30);
        expect(parsed.enableAutoArchive, true);
      });

      test('should handle null values with defaults', () {
        final json = {
          'themeMode': null,
          'defaultFormat': null,
          'scanDurationSeconds': null,
          'autoReconnect': null,
          'logRetentionDays': null,
          'enableAutoArchive': null,
        };
        final parsed = AppSettings.fromJson(json);
        expect(parsed.scanDurationSeconds, 30);
        expect(parsed.autoReconnect, false);
      });

      test('should perform roundtrip', () {
        const settings = AppSettings(
          themeMode: ThemeMode.dark,
          defaultFormat: DataDisplayFormat.BIN,
          scanDurationSeconds: 15,
          autoReconnect: true,
          logRetentionDays: 45,
          enableAutoArchive: false,
        );
        final json = settings.toJson();
        final restored = AppSettings.fromJson(json);
        expect(restored.themeMode, settings.themeMode);
        expect(restored.defaultFormat, settings.defaultFormat);
        expect(restored.scanDurationSeconds, settings.scanDurationSeconds);
        expect(restored.autoReconnect, settings.autoReconnect);
        expect(restored.logRetentionDays, settings.logRetentionDays);
        expect(restored.enableAutoArchive, settings.enableAutoArchive);
      });
    });
  });

  group('DataDisplayFormat enum', () {
    test('should have four values', () {
      expect(DataDisplayFormat.values.length, 4);
      expect(DataDisplayFormat.values, [
        DataDisplayFormat.HEX,
        DataDisplayFormat.ASCII,
        DataDisplayFormat.DEC,
        DataDisplayFormat.BIN,
      ]);
    });
  });
}
