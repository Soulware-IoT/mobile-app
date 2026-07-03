import 'package:cocina360/features/processes/domain/model/control_registry.dart';

sealed class NewRegistryState {
  const NewRegistryState();
}

final class NewRegistryIdle extends NewRegistryState {
  const NewRegistryIdle();
}

final class NewRegistrySubmitting extends NewRegistryState {
  const NewRegistrySubmitting();
}

final class NewRegistrySuccess extends NewRegistryState {
  final ControlRegistry registry;

  const NewRegistrySuccess(this.registry);
}

final class NewRegistryFailure extends NewRegistryState {
  final Object error;

  const NewRegistryFailure(this.error);
}
