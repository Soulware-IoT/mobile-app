import 'package:cocina360/features/devices/domain/model/device_quota.dart';
import 'package:cocina360/features/devices/domain/model/iot_device.dart';

/// The organization's device list together with its subscription quota, as
/// returned by `GET /organizations/{id}/iot-devices`.
class DevicesInventory {
  final List<IotDevice> devices;

  /// Null when the backend response carried no quota (older deployments).
  final DeviceQuota? quota;

  const DevicesInventory({required this.devices, this.quota});
}
