import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/settings_repository.dart';
import '../../../data/models/app_settings.dart';
import 'settings_event.dart';
import 'settings_state.dart';

/// BLoC managing application settings persistence and state.
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _settingsRepo;

  SettingsBloc({
    required SettingsRepository settingsRepo,
  })  : _settingsRepo = settingsRepo,
        super(const SettingsState()) {
    on<SettingsLoaded>(_onSettingsLoaded);
    on<ThemeChanged>(_onThemeChanged);
    on<FormatChanged>(_onFormatChanged);
    on<ScanDurationChanged>(_onScanDurationChanged);
    on<AutoReconnectToggled>(_onAutoReconnectToggled);
    on<LogRetentionChanged>(_onLogRetentionChanged);
    on<AutoArchiveToggled>(_onAutoArchiveToggled);
  }

  void _onSettingsLoaded(
    SettingsLoaded event,
    Emitter<SettingsState> emit,
  ) {
    final AppSettings settings = _settingsRepo.getSettings();
    emit(SettingsState(settings: settings, isLoaded: true));
  }

  Future<void> _onThemeChanged(
    ThemeChanged event,
    Emitter<SettingsState> emit,
  ) async {
    final AppSettings updated = state.settings.copyWith(
      themeMode: event.mode,
    );
    await _settingsRepo.saveSettings(updated);
    emit(state.copyWith(settings: updated));
  }

  Future<void> _onFormatChanged(
    FormatChanged event,
    Emitter<SettingsState> emit,
  ) async {
    final AppSettings updated = state.settings.copyWith(
      defaultFormat: event.format,
    );
    await _settingsRepo.saveSettings(updated);
    emit(state.copyWith(settings: updated));
  }

  Future<void> _onScanDurationChanged(
    ScanDurationChanged event,
    Emitter<SettingsState> emit,
  ) async {
    final AppSettings updated = state.settings.copyWith(
      scanDurationSeconds: event.seconds,
    );
    await _settingsRepo.saveSettings(updated);
    emit(state.copyWith(settings: updated));
  }

  Future<void> _onAutoReconnectToggled(
    AutoReconnectToggled event,
    Emitter<SettingsState> emit,
  ) async {
    final AppSettings updated = state.settings.copyWith(
      autoReconnect: event.enabled,
    );
    await _settingsRepo.saveSettings(updated);
    emit(state.copyWith(settings: updated));
  }

  Future<void> _onLogRetentionChanged(
    LogRetentionChanged event,
    Emitter<SettingsState> emit,
  ) async {
    final AppSettings updated = state.settings.copyWith(
      logRetentionDays: event.days,
    );
    await _settingsRepo.saveSettings(updated);
    emit(state.copyWith(settings: updated));
  }

  Future<void> _onAutoArchiveToggled(
    AutoArchiveToggled event,
    Emitter<SettingsState> emit,
  ) async {
    final AppSettings updated = state.settings.copyWith(
      enableAutoArchive: event.enabled,
    );
    await _settingsRepo.saveSettings(updated);
    emit(state.copyWith(settings: updated));
  }
}
