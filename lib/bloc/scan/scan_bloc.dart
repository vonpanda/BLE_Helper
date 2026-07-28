import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/ble_device.dart';
import '../../../data/models/log_entry.dart';
import '../../../data/models/scan_filter.dart';
import '../../../services/ble/ble_service_interface.dart';
import '../../../services/log/log_service.dart';
import 'scan_event.dart';
import 'scan_state.dart';

/// BLoC managing BLE device scanning lifecycle.
class ScanBloc extends Bloc<ScanEvent, ScanState> {
  final IBleService _bleService;
  final LogService _logService;

  StreamSubscription<List<BleDevice>>? _scanSubscription;
  Timer? _scanTimer;

  ScanBloc({
    required IBleService bleService,
    required LogService logService,
  })  : _bleService = bleService,
        _logService = logService,
        super(const ScanState()) {
    on<ScanStarted>(_onScanStarted);
    on<ScanStopped>(_onScanStopped);
    on<FilterChanged>(_onFilterChanged);
    on<ScanResultsReceived>(_onScanResultsReceived);
    on<ScanError>(_onScanError);
  }

  Future<void> _onScanStarted(
    ScanStarted event,
    Emitter<ScanState> emit,
  ) async {
    if (state.isScanning) {
      await _stopScan();
    }

    emit(state.copyWith(
      devices: event.clearResults ? const <BleDevice>[] : state.devices,
      isScanning: true,
      filter: event.filter,
      status: ScanStatus.scanning,
      clearError: true,
    ));

    try {
      // Apply scan duration timer
      const int scanDuration = AppConstants.defaultScanDurationSeconds;

      _scanTimer?.cancel();
      _scanTimer = Timer(const Duration(seconds: scanDuration), () {
        add(const ScanStopped());
      });

      await _scanSubscription?.cancel();
      _scanSubscription = _bleService.scanDevices(filter: event.filter).listen(
        (List<BleDevice> devices) {
          add(ScanResultsReceived(devices: devices));
        },
        onError: (Object error) {
          add(ScanError(message: error.toString()));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isScanning: false,
        status: ScanStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onScanResultsReceived(
    ScanResultsReceived event,
    Emitter<ScanState> emit,
  ) async {
    final List<BleDevice> filtered = _applyFilterAndSort(
      event.devices,
      state.filter,
    );
    final List<BleDevice> merged = List<BleDevice>.from(state.devices);
    final List<LogEntry> newDeviceLogs = [];

    for (final BleDevice device in filtered) {
      final int existingIdx = merged.indexWhere((d) => d.id == device.id);
      if (existingIdx >= 0) {
        merged[existingIdx] = device.copyWith(
          rssi: device.rssi,
          lastSeen: DateTime.now(),
        );
      } else {
        merged.add(device);
        newDeviceLogs.add(
          LogEntry(
            timestamp: DateTime.now(),
            deviceId: device.id,
            deviceName: device.name,
            eventType: LogEventType.SCAN_DEVICE_FOUND,
            description: 'Device found: ${device.name} (RSSI: ${device.rssi})',
          ),
        );
      }
    }

    emit(state.copyWith(
      devices: _applyFilterAndSort(merged, state.filter),
      isScanning: true,
      status: ScanStatus.scanning,
    ));

    for (final LogEntry logEntry in newDeviceLogs) {
      await _logService.log(logEntry);
    }
  }

  Future<void> _onScanStopped(
    ScanStopped event,
    Emitter<ScanState> emit,
  ) async {
    await _stopScan();
    emit(state.copyWith(
      isScanning: false,
      status: ScanStatus.idle,
    ));
  }

  void _onFilterChanged(FilterChanged event, Emitter<ScanState> emit) {
    // Apply filter to existing devices without restarting scan
    final List<BleDevice> filtered = _applyFilterAndSort(
      state.devices,
      event.filter,
    );

    emit(state.copyWith(
      filter: event.filter,
      devices: filtered,
    ));
  }

  void _onScanError(ScanError event, Emitter<ScanState> emit) {
    emit(state.copyWith(
      status: ScanStatus.error,
      errorMessage: event.message,
    ));
  }

  List<BleDevice> _applyFilterAndSort(
    List<BleDevice> devices,
    ScanFilter filter,
  ) {
    List<BleDevice> filtered = List<BleDevice>.from(devices);

    if (filter.nameFilter != null && filter.nameFilter!.isNotEmpty) {
      final String query = filter.nameFilter!.toLowerCase();
      filtered =
          filtered.where((d) => d.name.toLowerCase().contains(query)).toList();
    }

    if (filter.rssiMin != null) {
      filtered = filtered.where((d) => d.rssi >= filter.rssiMin!).toList();
    }

    switch (filter.sortBy) {
      case SortBy.RSSI:
        filtered.sort((a, b) => b.rssi.compareTo(a.rssi));
        break;
      case SortBy.NAME:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortBy.LAST_SEEN:
        filtered.sort((a, b) => b.lastSeen.compareTo(a.lastSeen));
        break;
    }

    if (filter.sortOrder == SortOrder.ASC) {
      return filtered.reversed.toList();
    }
    return filtered;
  }

  Future<void> _stopScan() async {
    _scanTimer?.cancel();
    _scanTimer = null;
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    await _bleService.stopScan();
  }

  @override
  Future<void> close() async {
    await _stopScan();
    return super.close();
  }
}
