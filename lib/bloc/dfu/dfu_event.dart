import 'package:equatable/equatable.dart';

import '../../../data/models/dfu_firmware.dart';

/// Base class for all DFU events.
sealed class DfuEvent extends Equatable {
  const DfuEvent();

  @override
  List<Object?> get props => [];
}

/// A firmware file was selected.
class FirmwareSelected extends DfuEvent {
  final DfuFirmware firmware;

  const FirmwareSelected({required this.firmware});

  @override
  List<Object?> get props => [firmware];
}

/// Start the DFU process.
class DfuStarted extends DfuEvent {
  final String deviceId;
  final DfuFirmware firmware;

  const DfuStarted({
    required this.deviceId,
    required this.firmware,
  });

  @override
  List<Object?> get props => [deviceId, firmware];
}

/// Abort the ongoing DFU.
class DfuAborted extends DfuEvent {
  const DfuAborted();
}

/// Progress update from the DFU adapter.
class DfuProgressUpdated extends DfuEvent {
  final int percent;

  const DfuProgressUpdated({required this.percent});

  @override
  List<Object?> get props => [percent];
}

/// DFU process completed successfully.
class DfuCompleted extends DfuEvent {
  const DfuCompleted();
}

/// DFU process failed with an error.
class DfuFailed extends DfuEvent {
  final String message;

  const DfuFailed({required this.message});

  @override
  List<Object?> get props => [message];
}
