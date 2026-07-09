import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cocina360/features/devices/domain/repositories/telemetry_repository.dart';
import 'package:cocina360/features/devices/presentation/cubit/servo_command_state.dart';

/// Sends start/stop servo commands for the device selected on the Live
/// Readings page. One in-flight command at a time.
class ServoCommandCubit extends Cubit<ServoCommandState> {
  final TelemetryRepository repository;

  ServoCommandCubit(this.repository) : super(const ServoIdle());

  Future<void> send(String deviceId, ServoCommand command) async {
    if (state is ServoSending) return;

    emit(ServoSending(command));
    try {
      await repository.sendServoCommand(deviceId, command);
      emit(ServoSuccess(command));
    } catch (e) {
      emit(ServoFailure(e));
    }
  }

  /// Clears success/failure when the user switches device.
  void reset() => emit(const ServoIdle());
}
