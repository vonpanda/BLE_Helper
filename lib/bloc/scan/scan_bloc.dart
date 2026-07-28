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
    on<ScanError>(_onScanError);
  }

  Future<void> _onScanStarted(
    ScanStarted event,
    Emitter<ScanState> emit,
  ) async {
    if (state.isScanning) {
      _stopScan();
    }

    emit(state.copyWith(
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

      _scanSubscription?.cancel();
      _scanSubscription = _bleService.scanDevices(filter: event.filter).listen(
        (List<BleDevice> devices) {
          List<BleDevice> filtered = List<BleDevice>.from(devices);

          // Apply name filter on client side
          if (event.filter.nameFilter != null &&
              event.filter.nameFilter!.isNotEmpty) {
            final String query = event.filter.nameFilter!.toLowerCase();
            filtered = filtered
                .where((d) => d.name.toLowerCase().contains(query))
                .toList();
          }

          // Apply RSSI filter
          if (event.filter.rssiMin != null) {
            filtered =
                filtered.where((d) => d.rssi >= event.filter.rssiMin!).toList();
          }

          // Sort
          switch (event.filter.sortBy) {
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

          if (event.filter.sortOrder == SortOrder.ASC) {
            filtered = filtered.reversed.toList();
          }

          for (final BleDevice device in filtered) {
            // Merge with existing if same ID
            final int existingIdx =
                state.devices.indexWhere((d) => d.id == device.id);
            if (existingIdx >= 0) {
              final List<BleDevice> updated =
                  List<BleDevice>.from(state.devices);
              updated[existingIdx] = device.copyWith(
                rssi: device.rssi,
                lastSeen: DateTime.now(),
              );
              emit(state.copyWith(devices: updated));
            } else {
              emit(state.copyWith(devices: [...state.devices, device]));
            }

            // Log device found (throttled: only log first time per device)
            if (existingIdx < 0) {
              _logService.log(
                LogEntry(
                  timestamp: DateTime.now(),
                  deviceId: device.id,
                  deviceName: device.name,
                  eventType: LogEventType.SCAN_DEVICE_FOUND,
                  description:
                      'Device found: ${device.name} (RSSI: ${device.rssi})',
                ),
              );
            }
          }
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

  void _onScanStopped(ScanStopped event, Emitter<ScanState> emit) {
    _stopScan();
    emit(state.copyWith(
      isScanning: false,
      status: ScanStatus.idle,
    ));
  }

  void _onFilterChanged(FilterChanged event, Emitter<ScanState> emit) {
    // Apply filter to existing devices without restarting scan
    List<BleDevice> filtered = List<BleDevice>.from(state.devices);

    if (event.filter.nameFilter != null &&
        event.filter.nameFilter!.isNotEmpty) {
      final String query = event.filter.nameFilter!.toLowerCase();
      filtered =
          filtered.where((d) => d.name.toLowerCase().contains(query)).toList();
    }

    if (event.filter.rssiMin != null) {
      filtered =
          filtered.where((d) => d.rssi >= event.filter.rssiMin!).toList();
    }

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

  void _stopScan() {
    _scanTimer?.cancel();
    _scanTimer = null;
    _scanSubscription?.cancel();
    _scanSubscription = null;
    _bleService.stopScan();
  }

  @override
  Future<void> close() {
    _stopScan();
    return super.close();
  }
}
