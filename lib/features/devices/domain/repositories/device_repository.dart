import 'package:cocina360/features/devices/domain/model/edge_device.dart';
import 'package:cocina360/features/devices/domain/model/iot_device.dart';

abstract class DeviceRepository {
  /// IoT devices owned by the organization.
  Future<List<IotDevice>> getDevices(String organizationId);

  /// A single IoT device by id (scoped to the organization for the gateway
  /// guard).
  Future<IotDevice> getDevice(String organizationId, String deviceId);

  /// The organization's edge gateway, or `null` when it has none yet.
  Future<EdgeDevice?> getEdgeDevice(String organizationId);
}
