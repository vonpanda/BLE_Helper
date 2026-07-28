import 'package:equatable/equatable.dart';

import '../../../data/models/connection_params.dart';
import '../../../services/ble/ble_service_interface.dart';

/// State for the DeviceBloc.
class DeviceState extends Equatable {
  final String deviceId;
  final ConnectionState connectionState;
  final int rssi;
  final int mtu;
  final ConnectionParams? connectionParams;
  final String? errorMessage;

  const DeviceState({
    this.deviceId = '',
    this.connectionState = ConnectionState.disconnected,
    this.rssi = -100,
    this.mtu = 23,
    this.connectionParams,
    this.errorMessage,
  });

  DeviceState copyWith({
    String? deviceId,
    ConnectionState? connectionState,
    int? rssi,
    int? mtu,
    ConnectionParams? connectionParams,
    String? errorMessage,
    bool clearConnectionParams = false,
    bool clearError = false,
  }) {
    return DeviceState(
      deviceId: deviceId ?? this.deviceId,
      connectionState: connectionState ?? this.connectionState,
      rssi: rssi ?? this.rssi,
      mtu: mtu ?? this.mtu,
      connectionParams: clearConnectionParams
          ? null
          : (connectionParams ?? this.connectionParams),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  bool get isConnected => connectionState == ConnectionState.connected;

  @override
  List<Object?> get props => [
        deviceId,
        connectionState,
        rssi,
        mtu,
        connectionParams,
        errorMessage,
      ];
}
