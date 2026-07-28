import 'dart:async';

import '../../../data/models/dfu_firmware.dart';
import 'dfu_adapter_interface.dart';

/// Manages multiple DFU adapters and routes DFU requests to the appropriate one.
class DfuManager {
  final List<IDfuAdapter> _adapters = [];
  IDfuAdapter? _activeAdapter;

  DfuManager();

  /// Register a DFU adapter.
  void registerAdapter(IDfuAdapter adapter) {
    _adapters.add(adapter);
  }

  /// Find the appropriate adapter for a given chip type.
  IDfuAdapter? getAdapterFor(DfuChipType chipType) {
    for (final IDfuAdapter adapter in _adapters) {
      if (adapter.isSupported(chipType)) {
        return adapter;
      }
    }
    return null;
  }

  /// Get the currently active adapter (during an ongoing DFU).
  IDfuAdapter? get activeAdapter => _activeAdapter;

  /// Start a DFU process. Selects the correct adapter based on firmware chip type.
  Future<void> startDfu(String deviceId, DfuFirmware firmware) async {
    final IDfuAdapter? adapter = getAdapterFor(firmware.chipType);
    if (adapter == null) {
      throw Exception(
          'No DFU adapter available for chip type: ${firmware.chipType.name}');
    }

    _activeAdapter = adapter;
    await adapter.startDfu(deviceId, firmware);
  }

  /// Abort the ongoing DFU process.
  Future<void> abortDfu() async {
    if (_activeAdapter != null) {
      await _activeAdapter!.abortDfu();
      _activeAdapter = null;
    }
  }

  /// Observe DFU progress from the active adapter.
  Stream<DfuProgress> observeProgress() {
    if (_activeAdapter == null) {
      return const Stream.empty();
    }
    return _activeAdapter!.observeProgress();
  }

  /// Observe DFU state changes from the active adapter.
  Stream<DfuAdapterState> observeState() {
    if (_activeAdapter == null) {
      return const Stream.empty();
    }
    return _activeAdapter!.observeState();
  }
}
