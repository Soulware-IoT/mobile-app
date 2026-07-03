import 'package:cocina360/features/devices/domain/model/iot_device.dart';

sealed class DeviceDetailState {
  const DeviceDetailState();
}

final class DeviceDetailInitial extends DeviceDetailState {
  const DeviceDetailInitial();
}

final class DeviceDetailLoading extends DeviceDetailState {
  const DeviceDetailLoading();
}

final class DeviceDetailLoaded extends DeviceDetailState {
  final IotDevice device;

  /// True while an update (rename / activation / thresholds) is in flight, so
  /// the controls can disable themselves without blanking the screen.
  final bool updating;

  /// Set when the last update failed; the page surfaces it as a snackbar and
  /// keeps showing the last known device.
  final Object? updateError;

  const DeviceDetailLoaded(
    this.device, {
    this.updating = false,
    this.updateError,
  });
}

final class DeviceDetailError extends DeviceDetailState {
  final Object error;

  const DeviceDetailError(this.error);
}
