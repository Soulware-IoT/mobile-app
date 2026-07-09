import 'package:cocina360/features/devices/domain/model/edge_device.dart';

sealed class EdgeDeviceDetailState {
  const EdgeDeviceDetailState();
}

final class EdgeDeviceDetailInitial extends EdgeDeviceDetailState {
  const EdgeDeviceDetailInitial();
}

final class EdgeDeviceDetailLoading extends EdgeDeviceDetailState {
  const EdgeDeviceDetailLoading();
}

final class EdgeDeviceDetailLoaded extends EdgeDeviceDetailState {
  final EdgeDevice device;

  /// True while an update (rename / activation) is in flight, so the
  /// controls can disable themselves without blanking the screen.
  final bool updating;

  /// Set when the last update failed; the page surfaces it as a snackbar and
  /// keeps showing the last known device.
  final Object? updateError;

  const EdgeDeviceDetailLoaded(
    this.device, {
    this.updating = false,
    this.updateError,
  });
}

final class EdgeDeviceDetailError extends EdgeDeviceDetailState {
  final Object error;

  const EdgeDeviceDetailError(this.error);
}
