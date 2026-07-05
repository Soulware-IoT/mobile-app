import 'package:cocina360/features/devices/domain/model/edge_device.dart';

sealed class ClaimEdgeDeviceState {
  const ClaimEdgeDeviceState();
}

final class ClaimEdgeDeviceInitial extends ClaimEdgeDeviceState {
  const ClaimEdgeDeviceInitial();
}

final class ClaimEdgeDeviceClaiming extends ClaimEdgeDeviceState {
  const ClaimEdgeDeviceClaiming();
}

final class ClaimEdgeDeviceSuccess extends ClaimEdgeDeviceState {
  final EdgeDevice device;

  const ClaimEdgeDeviceSuccess(this.device);
}

final class ClaimEdgeDeviceFailure extends ClaimEdgeDeviceState {
  final Object error;

  const ClaimEdgeDeviceFailure(this.error);
}
