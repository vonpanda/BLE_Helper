import 'package:equatable/equatable.dart';

import '../../../data/models/ble_service.dart';
import '../../../data/models/app_settings.dart';

/// Tracks the state of a single characteristic (read value, notify state, history).
class CharacteristicState {
  final List<int>? value;
  final bool isReading;
  final bool isWriting;
  final bool isNotifying;
  final bool isIndicating;
  final List<List<int>> notifyHistory;

  const CharacteristicState({
    this.value,
    this.isReading = false,
    this.isWriting = false,
    this.isNotifying = false,
    this.isIndicating = false,
    this.notifyHistory = const [],
  });

  CharacteristicState copyWith({
    List<int>? value,
    bool? isReading,
    bool? isWriting,
    bool? isNotifying,
    bool? isIndicating,
    List<List<int>>? notifyHistory,
    bool clearValue = false,
  }) {
    return CharacteristicState(
      value: clearValue ? null : (value ?? this.value),
      isReading: isReading ?? this.isReading,
      isWriting: isWriting ?? this.isWriting,
      isNotifying: isNotifying ?? this.isNotifying,
      isIndicating: isIndicating ?? this.isIndicating,
      notifyHistory: notifyHistory ?? this.notifyHistory,
    );
  }

  /// Append a value to notify history, keeping max 50 entries.
  CharacteristicState appendNotifyValue(List<int> value) {
    final List<List<int>> updated = List<List<int>>.from(notifyHistory);
    updated.add(List<int>.from(value));
    if (updated.length > 50) {
      updated.removeAt(0);
    }
    return CharacteristicState(
      value: List<int>.from(value),
      isNotifying: isNotifying,
      isIndicating: isIndicating,
      notifyHistory: updated,
    );
  }
}

/// State for the GattBloc.
class GattState extends Equatable {
  final List<BleServiceInfo> services;
  final bool isLoadingServices;
  final Map<String, CharacteristicState> characteristicStates;
  final DataDisplayFormat displayFormat;
  final String? errorMessage;

  const GattState({
    this.services = const [],
    this.isLoadingServices = false,
    this.characteristicStates = const {},
    this.displayFormat = DataDisplayFormat.HEX,
    this.errorMessage,
  });

  GattState copyWith({
    List<BleServiceInfo>? services,
    bool? isLoadingServices,
    Map<String, CharacteristicState>? characteristicStates,
    DataDisplayFormat? displayFormat,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GattState(
      services: services ?? this.services,
      isLoadingServices: isLoadingServices ?? this.isLoadingServices,
      characteristicStates: characteristicStates ?? this.characteristicStates,
      displayFormat: displayFormat ?? this.displayFormat,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  /// Build a key for the characteristicStates map.
  static String charKey(String serviceUuid, String charUuid) {
    return '$serviceUuid|$charUuid';
  }

  @override
  List<Object?> get props => [
        services,
        isLoadingServices,
        characteristicStates,
        displayFormat,
        errorMessage,
      ];
}
