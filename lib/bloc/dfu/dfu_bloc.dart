import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/log_entry.dart';
import '../../../services/dfu/dfu_manager.dart';
import '../../../services/log/log_service.dart';
import 'dfu_event.dart';
import 'dfu_state.dart';

/// BLoC managing the DFU firmware upgrade flow state machine.
class DfuBloc extends Bloc<DfuEvent, DfuState> {
  final DfuManager _dfuManager;
  final LogService _logService;

  DfuBloc({
    required DfuManager dfuManager,
    required LogService logService,
  })  : _dfuManager = dfuManager,
        _logService = logService,
        super(const DfuState()) {
    on<FirmwareSelected>(_onFirmwareSelected);
    on<DfuStarted>(_onDfuStarted);
    on<DfuAborted>(_onDfuAborted);
    on<DfuProgressUpdated>(_onProgressUpdated);
    on<DfuCompleted>(_onDfuCompleted);
    on<DfuFailed>(_onDfuFailed);
  }

  void _onFirmwareSelected(
    FirmwareSelected event,
    Emitter<DfuState> emit,
  ) {
    emit(DfuState(
      firmware: event.firmware,
      processState: DfuProcessState.READY,
    ));
  }

  Future<void> _onDfuStarted(
    DfuStarted event,
    Emitter<DfuState> emit,
  ) async {
    emit(state.copyWith(
      processState: DfuProcessState.IN_PROGRESS,
      progressPercent: 0,
      clearError: true,
    ));

    await _logService.log(
      LogEntry(
        timestamp: DateTime.now(),
        deviceId: event.deviceId,
        eventType: LogEventType.DFU_STARTED,
        description:
            'DFU started: ${event.firmware.fileName} (${event.firmware.firmwareVersion})',
      ),
    );

    try {
      await _dfuManager.startDfu(event.deviceId, event.firmware);

      // Listen to progress
      _dfuManager.observeProgress().listen(
        (dynamic progress) {
          if (progress.percent != null) {
            add(DfuProgressUpdated(percent: progress.percent as int));
          }
        },
      );

      add(const DfuCompleted());
    } catch (e) {
      add(DfuFailed(message: e.toString()));
    }
  }

  Future<void> _onDfuAborted(
    DfuAborted event,
    Emitter<DfuState> emit,
  ) async {
    try {
      await _dfuManager.abortDfu();
      emit(DfuState(
        firmware: state.firmware,
        processState: DfuProcessState.IDLE,
      ));
    } catch (e) {
      emit(state.copyWith(
        processState: DfuProcessState.FAILED,
        errorMessage: 'Abort failed: $e',
      ));
    }
  }

  void _onProgressUpdated(
    DfuProgressUpdated event,
    Emitter<DfuState> emit,
  ) {
    emit(state.copyWith(progressPercent: event.percent));

    _logService.log(
      LogEntry(
        timestamp: DateTime.now(),
        deviceId: '',
        eventType: LogEventType.DFU_PROGRESS,
        description: 'DFU progress: ${event.percent}%',
      ),
    );
  }

  void _onDfuCompleted(
    DfuCompleted event,
    Emitter<DfuState> emit,
  ) {
    emit(state.copyWith(
      processState: DfuProcessState.COMPLETED,
      progressPercent: 100,
    ));

    _logService.log(
      LogEntry(
        timestamp: DateTime.now(),
        deviceId: '',
        eventType: LogEventType.DFU_COMPLETED,
        description: 'DFU completed successfully',
      ),
    );
  }

  void _onDfuFailed(
    DfuFailed event,
    Emitter<DfuState> emit,
  ) {
    emit(state.copyWith(
      processState: DfuProcessState.FAILED,
      errorMessage: event.message,
    ));

    _logService.log(
      LogEntry(
        timestamp: DateTime.now(),
        deviceId: '',
        eventType: LogEventType.ERROR,
        description: 'DFU failed',
        errorDetail: event.message,
      ),
    );
  }
}
