import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ble_helper/bloc/settings/settings_bloc.dart';
import 'package:ble_helper/bloc/settings/settings_event.dart';
import 'package:ble_helper/bloc/settings/settings_state.dart';
import 'package:ble_helper/data/models/app_settings.dart';
import 'package:ble_helper/data/repositories/settings_repository.dart';

// --- Mocks ---

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockSettingsRepository mockRepo;

  const defaultSettings = AppSettings();

  setUpAll(() {
    registerFallbackValue(defaultSettings);
  });

  setUp(() {
    mockRepo = MockSettingsRepository();

    when(() => mockRepo.getSettings()).thenReturn(defaultSettings);
    when(() => mockRepo.saveSettings(any())).thenAnswer((_) async {});
  });

  group('SettingsBloc', () {
    // --- Initial State ---
    test('initial state should not be loaded', () {
      final bloc = SettingsBloc(settingsRepo: mockRepo);
      expect(bloc.state.isLoaded, false);
      expect(bloc.state.settings, const AppSettings());
    });

    // --- SettingsLoaded ---
    blocTest<SettingsBloc, SettingsState>(
      'should load settings from repository',
      build: () => SettingsBloc(settingsRepo: mockRepo),
      setUp: () {
        when(() => mockRepo.getSettings()).thenReturn(
          const AppSettings(
            themeMode: ThemeMode.dark,
            scanDurationSeconds: 60,
          ),
        );
      },
      act: (bloc) => bloc.add(const SettingsLoaded()),
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.isLoaded, 'isLoaded', true)
            .having((s) => s.settings.themeMode, 'theme', ThemeMode.dark)
            .having((s) => s.settings.scanDurationSeconds, 'scan duration', 60),
      ],
    );

    // --- ThemeChanged ---
    blocTest<SettingsBloc, SettingsState>(
      'should update theme mode',
      build: () => SettingsBloc(settingsRepo: mockRepo),
      seed: () =>
          const SettingsState(settings: defaultSettings, isLoaded: true),
      act: (bloc) => bloc.add(const ThemeChanged(mode: ThemeMode.light)),
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.settings.themeMode, 'theme', ThemeMode.light),
      ],
      verify: (_) {
        verify(() => mockRepo.saveSettings(any())).called(1);
      },
    );

    // --- FormatChanged ---
    blocTest<SettingsBloc, SettingsState>(
      'should update data display format',
      build: () => SettingsBloc(settingsRepo: mockRepo),
      seed: () =>
          const SettingsState(settings: defaultSettings, isLoaded: true),
      act: (bloc) =>
          bloc.add(const FormatChanged(format: DataDisplayFormat.BIN)),
      expect: () => [
        isA<SettingsState>().having(
            (s) => s.settings.defaultFormat, 'format', DataDisplayFormat.BIN),
      ],
    );

    // --- ScanDurationChanged ---
    blocTest<SettingsBloc, SettingsState>(
      'should update scan duration',
      build: () => SettingsBloc(settingsRepo: mockRepo),
      seed: () =>
          const SettingsState(settings: defaultSettings, isLoaded: true),
      act: (bloc) => bloc.add(const ScanDurationChanged(seconds: 120)),
      expect: () => [
        isA<SettingsState>().having(
            (s) => s.settings.scanDurationSeconds, 'scan duration', 120),
      ],
    );

    // --- AutoReconnectToggled ---
    blocTest<SettingsBloc, SettingsState>(
      'should toggle auto reconnect',
      build: () => SettingsBloc(settingsRepo: mockRepo),
      seed: () =>
          const SettingsState(settings: defaultSettings, isLoaded: true),
      act: (bloc) => bloc.add(const AutoReconnectToggled(enabled: true)),
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.settings.autoReconnect, 'auto reconnect', true),
      ],
    );

    // --- LogRetentionChanged ---
    blocTest<SettingsBloc, SettingsState>(
      'should update log retention days',
      build: () => SettingsBloc(settingsRepo: mockRepo),
      seed: () =>
          const SettingsState(settings: defaultSettings, isLoaded: true),
      act: (bloc) => bloc.add(const LogRetentionChanged(days: 90)),
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.settings.logRetentionDays, 'retention days', 90),
      ],
    );

    // --- AutoArchiveToggled ---
    blocTest<SettingsBloc, SettingsState>(
      'should toggle auto archive',
      build: () => SettingsBloc(settingsRepo: mockRepo),
      seed: () =>
          const SettingsState(settings: defaultSettings, isLoaded: true),
      act: (bloc) => bloc.add(const AutoArchiveToggled(enabled: false)),
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.settings.enableAutoArchive, 'auto archive', false),
      ],
    );

    // --- Multiple events in sequence ---
    blocTest<SettingsBloc, SettingsState>(
      'should handle multiple settings changes in sequence',
      build: () => SettingsBloc(settingsRepo: mockRepo),
      seed: () =>
          const SettingsState(settings: defaultSettings, isLoaded: true),
      act: (bloc) {
        bloc.add(const ThemeChanged(mode: ThemeMode.dark));
        bloc.add(const ScanDurationChanged(seconds: 45));
        bloc.add(const AutoReconnectToggled(enabled: true));
      },
      expect: () => [
        isA<SettingsState>()
            .having((s) => s.settings.themeMode, 'theme', ThemeMode.dark),
        isA<SettingsState>()
            .having((s) => s.settings.scanDurationSeconds, 'scan', 45)
            .having(
                (s) => s.settings.themeMode, 'theme preserved', ThemeMode.dark),
        isA<SettingsState>()
            .having((s) => s.settings.autoReconnect, 'reconnect', true)
            .having((s) => s.settings.scanDurationSeconds, 'scan preserved', 45)
            .having(
                (s) => s.settings.themeMode, 'theme preserved', ThemeMode.dark),
      ],
    );
  });

  group('SettingsState', () {
    test('copyWith should preserve values', () {
      const state = SettingsState(
        settings: AppSettings(themeMode: ThemeMode.dark),
        isLoaded: true,
      );
      final copied = state.copyWith();
      expect(copied.settings.themeMode, ThemeMode.dark);
      expect(copied.isLoaded, true);
    });

    test('props should contain settings and isLoaded', () {
      const state = SettingsState();
      expect(state.props.length, 2);
    });
  });
}
