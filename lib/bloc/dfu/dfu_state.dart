import 'package:equatable/equatable.dart';

import '../../../data/models/dfu_firmware.dart';

/// DFU process states.
enum DfuProcessState {
  IDLE,
  READY,
  IN_PROGRESS,
  COMPLETED,
  FAILED,
}

/// State for the DfuBloc.
class DfuState extends Equatable {
  final DfuFirmware? firmware;
  final DfuProcessState processState;
  final int progressPercent;
  final String? errorMessage;

  const DfuState({
    this.firmware,
    this.processState = DfuProcessState.IDLE,
    this.progressPercent = 0,
    this.errorMessage,
  });

  DfuState copyWith({
    DfuFirmware? firmware,
    DfuProcessState? processState,
    int? progressPercent,
    String? errorMessage,
    bool clearFirmware = false,
    bool clearError = false,
  }) {
    return DfuState(
      firmware: clearFirmware ? null : (firmware ?? this.firmware),
      processState: processState ?? this.processState,
      progressPercent: progressPercent ?? this.progressPercent,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  bool get isReady => processState == DfuProcessState.READY;
  bool get isInProgress => processState == DfuProcessState.IN_PROGRESS;
  bool get isCompleted => processState == DfuProcessState.COMPLETED;
  bool get isFailed => processState == DfuProcessState.FAILED;

  @override
  List<Object?> get props => [
        firmware,
        processState,
        progressPercent,
        errorMessage,
      ];
}
