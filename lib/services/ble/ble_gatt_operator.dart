import 'dart:async';
import 'dart:collection';

import 'ble_service_interface.dart';

/// Represents a GATT operation that can be queued.
class GattOperation {
  final String serviceUuid;
  final String characterUuid;
  final String? descriptorUuid;
  final List<int>? data;
  final bool? withResponse;
  final bool? enableNotify;
  final bool isRead;
  final bool isWrite;
  final bool isNotify;
  final bool isDescriptor;
  final Completer<dynamic> completer;

  GattOperation({
    required this.serviceUuid,
    required this.characterUuid,
    this.descriptorUuid,
    this.data,
    this.withResponse,
    this.enableNotify,
    this.isRead = false,
    this.isWrite = false,
    this.isNotify = false,
    this.isDescriptor = false,
  }) : completer = Completer<dynamic>();
}

/// Manages a serialized operation queue for GATT operations on a single device.
/// Ensures that GATT operations are executed one at a time per device.
class BleGattOperator {
  final String _deviceId;
  final IBleService _bleService;

  final Queue<GattOperation> _operationQueue = Queue<GattOperation>();
  bool _isProcessing = false;

  BleGattOperator({
    required String deviceId,
    required IBleService bleService,
  })  : _deviceId = deviceId,
        _bleService = bleService;

  /// Enqueue a read characteristic operation.
  Future<List<int>> enqueueRead(String serviceUuid, String charUuid) {
    final GattOperation operation = GattOperation(
      serviceUuid: serviceUuid,
      characterUuid: charUuid,
      isRead: true,
    );
    _operationQueue.add(operation);
    _processQueue();
    return operation.completer.future
        .then((dynamic result) => result as List<int>);
  }

  /// Enqueue a write characteristic operation.
  Future<void> enqueueWrite(
    String serviceUuid,
    String charUuid,
    List<int> data,
    bool withResponse,
  ) {
    final GattOperation operation = GattOperation(
      serviceUuid: serviceUuid,
      characterUuid: charUuid,
      data: data,
      withResponse: withResponse,
      isWrite: true,
    );
    _operationQueue.add(operation);
    _processQueue();
    return operation.completer.future.then((_) {});
  }

  /// Enqueue a set-notify operation.
  Future<void> enqueueSetNotify(
    String serviceUuid,
    String charUuid,
    bool enable,
  ) {
    final GattOperation operation = GattOperation(
      serviceUuid: serviceUuid,
      characterUuid: charUuid,
      enableNotify: enable,
      isNotify: true,
    );
    _operationQueue.add(operation);
    _processQueue();
    return operation.completer.future.then((_) {});
  }

  /// Enqueue a read descriptor operation.
  Future<List<int>> enqueueReadDescriptor(
    String serviceUuid,
    String charUuid,
    String descUuid,
  ) {
    final GattOperation operation = GattOperation(
      serviceUuid: serviceUuid,
      characterUuid: charUuid,
      descriptorUuid: descUuid,
      isDescriptor: true,
      isRead: true,
    );
    _operationQueue.add(operation);
    _processQueue();
    return operation.completer.future
        .then((dynamic result) => result as List<int>);
  }

  /// Dispose of the operator, clearing the queue with errors.
  void dispose() {
    for (final GattOperation op in _operationQueue) {
      if (!op.completer.isCompleted) {
        op.completer.completeError(Exception('GATT operator disposed'));
      }
    }
    _operationQueue.clear();
    _isProcessing = false;
  }

  /// Process the operation queue serially.
  Future<void> _processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    while (_operationQueue.isNotEmpty) {
      final GattOperation operation = _operationQueue.first;

      try {
        if (operation.isRead && operation.isDescriptor) {
          final List<int> result = await _bleService.readDescriptor(
            _deviceId,
            operation.serviceUuid,
            operation.characterUuid,
            operation.descriptorUuid!,
          );
          if (!operation.completer.isCompleted) {
            operation.completer.complete(result);
          }
        } else if (operation.isRead) {
          final List<int> result = await _bleService.readCharacteristic(
            _deviceId,
            operation.serviceUuid,
            operation.characterUuid,
          );
          if (!operation.completer.isCompleted) {
            operation.completer.complete(result);
          }
        } else if (operation.isWrite) {
          await _bleService.writeCharacteristic(
            _deviceId,
            operation.serviceUuid,
            operation.characterUuid,
            operation.data!,
            operation.withResponse ?? true,
          );
          if (!operation.completer.isCompleted) {
            operation.completer.complete();
          }
        } else if (operation.isNotify) {
          await _bleService.setNotify(
            _deviceId,
            operation.serviceUuid,
            operation.characterUuid,
            operation.enableNotify ?? false,
          );
          if (!operation.completer.isCompleted) {
            operation.completer.complete();
          }
        }
      } catch (e) {
        if (!operation.completer.isCompleted) {
          operation.completer.completeError(e);
        }
      }

      _operationQueue.removeFirst();
    }

    _isProcessing = false;
  }
}
