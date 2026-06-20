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

  const DeviceDetailLoaded(this.device);
}

final class DeviceDetailError extends DeviceDetailState {
  final Object error;

  const DeviceDetailError(this.error);
}
