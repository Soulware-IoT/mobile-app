import 'package:cocina360/features/devices/domain/model/devices_inventory.dart';
import 'package:cocina360/features/devices/domain/model/edge_device.dart';
import 'package:cocina360/features/devices/domain/model/iot_device.dart';
import 'package:cocina360/features/devices/domain/model/thresholds.dart';

abstract class DeviceRepository {
  /// IoT devices owned by the organization, plus its subscription quota.
  Future<DevicesInventory> getDevices(String organizationId);

  /// A single IoT device by id. The backend resolves the owning organization
  /// and authorizes from the JWT.
  Future<IotDevice> getDevice(String deviceId);

  /// Claims a factory-provisioned IoT device by its code into the
  /// organization. Omit [thresholds] to apply the backend's standard
  /// defaults (35/50 °C, 1000/3000 PPM).
  Future<IotDevice> claimDevice({
    required String organizationId,
    required String code,
    required String name,
    Thresholds? thresholds,
  });

  /// Partial update of a claimed device. Omitted fields are left unchanged;
  /// [active] maps to the backend's `status` (ACTIVE / INACTIVE).
  Future<IotDevice> updateDevice(
    String deviceId, {
    String? name,
    Thresholds? thresholds,
    bool? active,
  });

  /// The organization's edge gateway, or `null` when it has none yet.
  Future<EdgeDevice?> getEdgeDevice(String organizationId);

  /// Claims a factory-provisioned edge gateway by its code into the
  /// organization. An organization has at most one edge device.
  Future<EdgeDevice> claimEdgeDevice({
    required String organizationId,
    required String code,
    required String name,
  });
}
