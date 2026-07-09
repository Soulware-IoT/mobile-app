import 'package:cocina360/features/devices/domain/repositories/telemetry_repository.dart';

sealed class ServoCommandState {
  const ServoCommandState();
}

final class ServoIdle extends ServoCommandState {
  const ServoIdle();
}

final class ServoSending extends ServoCommandState {
  final ServoCommand command;

  const ServoSending(this.command);
}

final class ServoSuccess extends ServoCommandState {
  final ServoCommand command;

  const ServoSuccess(this.command);
}

final class ServoFailure extends ServoCommandState {
  final Object error;

  const ServoFailure(this.error);
}
