import 'package:equatable/equatable.dart';

import '../../../data/models/app_settings.dart';

/// State for the SettingsBloc.
class SettingsState extends Equatable {
  final AppSettings settings;
  final bool isLoaded;

  const SettingsState({
    this.settings = const AppSettings(),
    this.isLoaded = false,
  });

  SettingsState copyWith({
    AppSettings? settings,
    bool? isLoaded,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

  @override
  List<Object?> get props => [settings, isLoaded];
}
