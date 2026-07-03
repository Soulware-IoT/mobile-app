import 'package:cocina360/features/devices/domain/model/device_status.dart';
import 'package:cocina360/features/devices/domain/model/iot_device.dart';
import 'package:cocina360/features/devices/domain/model/thresholds.dart';
import 'package:cocina360/shared/data/types/json.dart';

/// Maps the backend `IoTDeviceResponse` (served through the api-gw) into the
/// [IotDevice] domain model. Live readings are not part of this payload — only
/// the device's identity, status and configured thresholds.
///
/// Wire shape (backend `develop`): `id`, `organizationId`, `code`, `name`,
/// `status`, `thresholds: {temperature: {warn, crit}, gas: {warn, crit}}`,
/// audit fields. `organizationId`/`name` are null while still PROVISIONED.
class IotDeviceDto {
  final String deviceId;
  final String? organizationId;
  final String code;
  final String? name;
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
      // `id` is the current contract; `deviceId` kept as a fallback for older
      // backend deployments.
      deviceId: (json['id'] ?? json['deviceId']) as String,
      organizationId: json['organizationId'] as String?,
      code: json['code'] as String,
      name: json['name'] as String?,
      status: json['status'] as String?,
      thresholds: json['thresholds'] as JSON?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  IotDevice toDomain() {
    return IotDevice(
      deviceId: deviceId,
      organizationId: organizationId ?? '',
      code: code,
      name: name ?? code,
      status: deviceStatusFromString(status),
      thresholds: _thresholds(),
      createdAt: DateTime.tryParse(createdAt ?? ''),
      updatedAt: DateTime.tryParse(updatedAt ?? ''),
    );
  }

  /// Thresholds arrive nested (`temperature.warn/crit`, `gas.warn/crit`); the
  /// legacy flat shape (`warnTemperatureC`, ...) is still read as a fallback.
  Thresholds _thresholds() {
    final t = thresholds;
    if (t == null) return const Thresholds();

    final temperature = t['temperature'];
    final gas = t['gas'];
    if (temperature is Map || gas is Map) {
      return Thresholds(
        warnTemperatureC: _asInt(temperature, 'warn'),
        critTemperatureC: _asInt(temperature, 'crit'),
        warnGasPpm: _asDouble(gas, 'warn'),
        critGasPpm: _asDouble(gas, 'crit'),
      );
    }

    return Thresholds(
      warnTemperatureC: (t['warnTemperatureC'] as num?)?.toInt(),
      critTemperatureC: (t['critTemperatureC'] as num?)?.toInt(),
      warnGasPpm: (t['warnGasPpm'] as num?)?.toDouble(),
      critGasPpm: (t['critGasPpm'] as num?)?.toDouble(),
    );
  }

  static int? _asInt(Object? map, String key) =>
      map is Map ? (map[key] as num?)?.toInt() : null;

  static double? _asDouble(Object? map, String key) =>
      map is Map ? (map[key] as num?)?.toDouble() : null;
}
