import 'package:cocina360/features/devices/domain/model/device_status.dart';
import 'package:cocina360/features/devices/domain/model/edge_device.dart';
import 'package:cocina360/features/devices/domain/model/iot_device.dart';

sealed class DevicesState {
  const DevicesState();
}

final class DevicesInitial extends DevicesState {
  const DevicesInitial();
}

final class DevicesLoading extends DevicesState {
  const DevicesLoading();
}

final class DevicesLoaded extends DevicesState {
  final List<IotDevice> devices;

  /// The org's edge gateway, or null when it has none.
  final EdgeDevice? edge;

  const DevicesLoaded(this.devices, this.edge);

  int get activeCount =>
      devices.where((d) => d.status == DeviceStatus.active).length;
}

final class DevicesError extends DevicesState {
  /// The raw error, rendered to a localized string by the page via
  /// `localizedError`.
  final Object error;

  const DevicesError(this.error);
}
