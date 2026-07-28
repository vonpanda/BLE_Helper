import 'package:equatable/equatable.dart';

import '../../../data/models/ble_device.dart';
import '../../../data/models/scan_filter.dart';

/// Represents the scan status.
enum ScanStatus { idle, scanning, stopping, error }

/// State for the ScanBloc.
class ScanState extends Equatable {
  final List<BleDevice> devices;
  final bool isScanning;
  final ScanFilter filter;
  final ScanStatus status;
  final String? errorMessage;
  final bool comparisonActive;
  final List<String> comparisonBaselineDeviceIds;
  final List<String> highlightedDeviceIds;

  const ScanState({
    this.devices = const [],
    this.isScanning = false,
    this.filter = const ScanFilter(),
    this.status = ScanStatus.idle,
    this.errorMessage,
    this.comparisonActive = false,
    this.comparisonBaselineDeviceIds = const [],
    this.highlightedDeviceIds = const [],
  });

  ScanState copyWith({
    List<BleDevice>? devices,
    bool? isScanning,
    ScanFilter? filter,
    ScanStatus? status,
    String? errorMessage,
    bool? comparisonActive,
    List<String>? comparisonBaselineDeviceIds,
    List<String>? highlightedDeviceIds,
    bool clearError = false,
  }) {
    return ScanState(
      devices: devices ?? this.devices,
      isScanning: isScanning ?? this.isScanning,
      filter: filter ?? this.filter,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      comparisonActive: comparisonActive ?? this.comparisonActive,
      comparisonBaselineDeviceIds:
          comparisonBaselineDeviceIds ?? this.comparisonBaselineDeviceIds,
      highlightedDeviceIds: highlightedDeviceIds ?? this.highlightedDeviceIds,
    );
  }

  bool isHighlighted(String deviceId) =>
      highlightedDeviceIds.contains(deviceId);

  @override
  List<Object?> get props => [
        devices,
        isScanning,
        filter,
        status,
        errorMessage,
        comparisonActive,
        comparisonBaselineDeviceIds,
        highlightedDeviceIds,
      ];
}
