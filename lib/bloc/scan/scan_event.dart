import 'package:equatable/equatable.dart';

import '../../../data/models/scan_filter.dart';

/// Base class for all scan-related events.
sealed class ScanEvent extends Equatable {
  const ScanEvent();

  @override
  List<Object?> get props => [];
}

/// Start scanning with optional filter.
class ScanStarted extends ScanEvent {
  final ScanFilter filter;

  const ScanStarted({this.filter = const ScanFilter()});

  @override
  List<Object?> get props => [filter];
}

/// Stop the current scan.
class ScanStopped extends ScanEvent {
  const ScanStopped();
}

/// Update the scan filter (applied client-side to existing results).
class FilterChanged extends ScanEvent {
  final ScanFilter filter;

  const FilterChanged({required this.filter});

  @override
  List<Object?> get props => [filter];
}

/// A new device was found during scanning.
class ScanDeviceFound extends ScanEvent {
  final dynamic device; // BleDevice

  const ScanDeviceFound(this.device);

  @override
  List<Object?> get props => [device];
}

/// An error occurred during scanning.
class ScanError extends ScanEvent {
  final String message;

  const ScanError({required this.message});

  @override
  List<Object?> get props => [message];
}
