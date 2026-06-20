import 'package:cocina360/features/devices/domain/model/device_status.dart';
import 'package:cocina360/features/devices/domain/model/iot_device.dart';
import 'package:cocina360/features/devices/domain/model/thresholds.dart';
import 'package:cocina360/shared/data/types/json.dart';

/// Maps the backend `IoTDeviceResponse` (served through the api-gw) into the
/// [IotDevice] domain model. Live readings are not part of this payload — only
/// the device's identity, status and configured thresholds.
class IotDeviceDto {
  final String deviceId;
  final String organizationId;
  final String code;
  final String name;
  final String? status;
  final JSON? thresholds;
  final String? createdAt;
  final String? updatedAt;

  const IotDeviceDto({
    required this.deviceId,
    required this.organizationId,
    required this.code,
    required this.name,
    this.status,
    this.thresholds,
    this.createdAt,
    this.updatedAt,
  });

  factory IotDeviceDto.fromJson(JSON json) {
    return IotDeviceDto(
      deviceId: json['deviceId'] as String,
      organizationId: json['organizationId'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      status: json['status'] as String?,
      thresholds: json['thresholds'] as JSON?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  IotDevice toDomain() {
    return IotDevice(
      deviceId: deviceId,
      organizationId: organizationId,
      code: code,
      name: name,
      status: deviceStatusFromString(status),
      thresholds: _thresholds(),
      createdAt: DateTime.tryParse(createdAt ?? ''),
      updatedAt: DateTime.tryParse(updatedAt ?? ''),
    );
  }

  Thresholds _thresholds() {
    final t = thresholds;
    if (t == null) return const Thresholds();
    return Thresholds(
      warnTemperatureC: (t['warnTemperatureC'] as num?)?.toInt(),
      critTemperatureC: (t['critTemperatureC'] as num?)?.toInt(),
      warnGasPpm: (t['warnGasPpm'] as num?)?.toDouble(),
      critGasPpm: (t['critGasPpm'] as num?)?.toDouble(),
    );
  }
}
