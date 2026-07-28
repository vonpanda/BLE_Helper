import 'dart:async';

// import 'package:flutter_nordic_dfu/flutter_nordic_dfu.dart' as nordic; // Temporarily disabled

import '../../../data/models/dfu_firmware.dart';
import 'dfu_adapter_interface.dart';

/// Nordic Semiconductor DFU adapter implementation using flutter_nordic_dfu.
class NordicDfuAdapter implements IDfuAdapter {
  final StreamController<DfuProgress> _progressController =
      StreamController<DfuProgress>.broadcast();
  final StreamController<DfuAdapterState> _stateController =
      StreamController<DfuAdapterState>.broadcast();

  NordicDfuAdapter();

  @override
  bool isSupported(DfuChipType chipType) {
    return chipType == DfuChipType.NORDIC || chipType == DfuChipType.CUSTOM;
  }

  @override
  DfuChipType get chipType => DfuChipType.NORDIC;

  @override
  Future<void> startDfu(String deviceId, DfuFirmware firmware) async {
    _stateController.add(DfuAdapterState.FAILED);
    throw UnsupportedError(
      'Nordic DFU backend is not configured. Add a platform DFU package '
      'before enabling firmware upgrades.',
    );
  }

  @override
  Future<void> abortDfu() async {
    _stateController.add(DfuAdapterState.ABORTED);
  }

  @override
  Stream<DfuProgress> observeProgress() {
    return _progressController.stream;
  }

  @override
  Stream<DfuAdapterState> observeState() {
    return _stateController.stream;
  }
}
