import 'dart:async';

import '../../../data/models/dfu_firmware.dart';

/// Progress information during DFU firmware upload.
class DfuProgress {
  final int percent;
  final int bytesSent;
  final int totalBytes;
  final double speedKbps;

  const DfuProgress({
    this.percent = 0,
    this.bytesSent = 0,
    this.totalBytes = 0,
    this.speedKbps = 0.0,
  });

  @override
  String toString() =>
      'DfuProgress($percent%, $bytesSent/$totalBytes, ${speedKbps.toStringAsFixed(1)} KB/s)';
}

/// DFU adapter state machine states.
enum DfuAdapterState {
  IDLE,
  CONNECTING,
  UPLOADING,
  VERIFYING,
  COMPLETED,
  FAILED,
  ABORTED,
}

/// Abstract interface for DFU (Device Firmware Update) adapters.
/// Each chip type (Nordic, TI, Dialog) has its own adapter implementation.
abstract class IDfuAdapter {
  /// Whether this adapter supports the given chip type.
  bool isSupported(DfuChipType chipType);

  /// The chip type this adapter handles.
  DfuChipType get chipType;

  /// Start the DFU process for a device.
  Future<void> startDfu(String deviceId, DfuFirmware firmware);

  /// Abort an ongoing DFU process.
  Future<void> abortDfu();

  /// Stream of progress updates during DFU.
  Stream<DfuProgress> observeProgress();

  /// Stream of state changes during DFU.
  Stream<DfuAdapterState> observeState();
}
