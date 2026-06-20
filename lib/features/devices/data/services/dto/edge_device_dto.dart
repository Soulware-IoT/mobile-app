import 'package:cocina360/features/devices/domain/model/device_status.dart';
import 'package:cocina360/features/devices/domain/model/edge_device.dart';
import 'package:cocina360/shared/data/types/json.dart';

/// Maps the backend `EdgeDeviceResponse` into the [EdgeDevice] domain model.
class EdgeDeviceDto {
  final String edgeDeviceId;
  final String code;
  final String name;
  final String? status;

  const EdgeDeviceDto({
    required this.edgeDeviceId,
    required this.code,
    required this.name,
    this.status,
  });

  factory EdgeDeviceDto.fromJson(JSON json) {
    return EdgeDeviceDto(
      edgeDeviceId: json['edgeDeviceId'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      status: json['status'] as String?,
    );
  }

  EdgeDevice toDomain() {
    return EdgeDevice(
      edgeDeviceId: edgeDeviceId,
      code: code,
      name: name,
      status: deviceStatusFromString(status),
    );
  }
}
