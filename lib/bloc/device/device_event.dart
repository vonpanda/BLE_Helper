import 'package:equatable/equatable.dart';

import '../../../services/ble/ble_service_interface.dart';

/// Base class for all device-related events.
sealed class DeviceEvent extends Equatable {
  const DeviceEvent();

  @override
  List<Object?> get props => [];
}

/// Request to connect to a device.
class ConnectRequested extends DeviceEvent {
  final String deviceId;

  const ConnectRequested({required this.deviceId});

  @override
  List<Object?> get props => [deviceId];
}

/// Request to disconnect from the current device.
class DisconnectRequested extends DeviceEvent {
  const DisconnectRequested();
}

/// Request to change the MTU.
class MtuRequested extends DeviceEvent {
  final int mtu;

  const MtuRequested({required this.mtu});

  @override
  List<Object?> get props => [mtu];
}

/// RSSI value updated.
class RssiUpdated extends DeviceEvent {
  final int rssi;

  const RssiUpdated({required this.rssi});

  @override
  List<Object?> get props => [rssi];
}

/// Connection state changed (from stream).
class ConnectionStateChanged extends DeviceEvent {
  final ConnectionState connectionState;

  const ConnectionStateChanged({required this.connectionState});

  @override
  List<Object?> get props => [connectionState];
}

/// An error occurred during device operations.
class DeviceError extends DeviceEvent {
  final String message;

  const DeviceError({required this.message});

  @override
  List<Object?> get props => [message];
}
