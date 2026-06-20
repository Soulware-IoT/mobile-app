import 'package:cocina360/features/devices/domain/model/device_status.dart';

/// The single edge gateway that serves an organization's IoT devices.
class EdgeDevice {
  final String edgeDeviceId;
  final String code;
  final String name;
  final DeviceStatus status;

  const EdgeDevice({
    required this.edgeDeviceId,
    required this.code,
    required this.name,
    required this.status,
  });
}
