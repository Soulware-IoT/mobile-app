import 'package:cocina360/features/devices/domain/model/device_status.dart';
import 'package:cocina360/features/devices/domain/model/thresholds.dart';

/// An IoT sensor device claimed by an organization.
class IotDevice {
  final String deviceId;
  final String organizationId;
  final String code;
  final String name;
  final DeviceStatus status;
  final Thresholds thresholds;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const IotDevice({
    required this.deviceId,
    required this.organizationId,
    required this.code,
    required this.name,
    required this.status,
    required this.thresholds,
    this.createdAt,
    this.updatedAt,
  });
}
