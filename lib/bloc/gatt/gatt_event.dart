import 'package:equatable/equatable.dart';

/// Base class for all GATT-related events.
sealed class GattEvent extends Equatable {
  const GattEvent();

  @override
  List<Object?> get props => [];
}

/// Discover GATT services on the connected device.
class DiscoverServices extends GattEvent {
  const DiscoverServices();
}

/// Read a characteristic value.
class ReadCharacteristic extends GattEvent {
  final String serviceUuid;
  final String charUuid;

  const ReadCharacteristic({
    required this.serviceUuid,
    required this.charUuid,
  });

  @override
  List<Object?> get props => [serviceUuid, charUuid];
}

/// Write data to a characteristic.
class WriteCharacteristic extends GattEvent {
  final String serviceUuid;
  final String charUuid;
  final List<int> data;
  final bool withResponse;

  const WriteCharacteristic({
    required this.serviceUuid,
    required this.charUuid,
    required this.data,
    this.withResponse = true,
  });

  @override
  List<Object?> get props => [serviceUuid, charUuid, data, withResponse];
}

/// Toggle notification/indication on a characteristic.
class ToggleNotify extends GattEvent {
  final String serviceUuid;
  final String charUuid;
  final bool enable;

  const ToggleNotify({
    required this.serviceUuid,
    required this.charUuid,
    required this.enable,
  });

  @override
  List<Object?> get props => [serviceUuid, charUuid, enable];
}

/// Read a descriptor value.
class ReadDescriptor extends GattEvent {
  final String serviceUuid;
  final String charUuid;
  final String descUuid;

  const ReadDescriptor({
    required this.serviceUuid,
    required this.charUuid,
    required this.descUuid,
  });

  @override
  List<Object?> get props => [serviceUuid, charUuid, descUuid];
}

/// Notification value received from the hardware stream.
class NotifyValueReceived extends GattEvent {
  final String serviceUuid;
  final String charUuid;
  final List<int> value;

  const NotifyValueReceived({
    required this.serviceUuid,
    required this.charUuid,
    required this.value,
  });

  @override
  List<Object?> get props => [serviceUuid, charUuid, value];
}

/// A GATT operation error occurred.
class GattError extends GattEvent {
  final String message;

  const GattError({required this.message});

  @override
  List<Object?> get props => [message];
}
