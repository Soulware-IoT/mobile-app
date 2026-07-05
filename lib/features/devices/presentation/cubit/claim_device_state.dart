import 'package:cocina360/features/devices/domain/model/iot_device.dart';

sealed class ClaimDeviceState {
  const ClaimDeviceState();
}

final class ClaimDeviceInitial extends ClaimDeviceState {
  const ClaimDeviceInitial();
}

final class ClaimDeviceClaiming extends ClaimDeviceState {
  const ClaimDeviceClaiming();
}

final class ClaimDeviceSuccess extends ClaimDeviceState {
  final IotDevice device;

  const ClaimDeviceSuccess(this.device);
}

final class ClaimDeviceFailure extends ClaimDeviceState {
  final Object error;

  const ClaimDeviceFailure(this.error);
}
