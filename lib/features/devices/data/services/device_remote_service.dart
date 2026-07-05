import 'package:cocina360/features/devices/data/services/dto/edge_device_dto.dart';
import 'package:cocina360/features/devices/data/services/dto/iot_device_dto.dart';
import 'package:cocina360/shared/data/types/json.dart';
import 'package:cocina360/shared/infrastructure/remote/api_gateway_client.dart';

/// The org's device list plus its subscription quota, as served by the api-gw.
class DeviceListDto {
  final List<IotDeviceDto> devices;
  final int? quotaUsed;
  final int? quotaLimit;

  const DeviceListDto({
    required this.devices,
    this.quotaUsed,
    this.quotaLimit,
  });
}

/// Talks to the backend's Security context through the api-gw.
class DeviceRemoteService {
  final ApiGatewayClient client;

  DeviceRemoteService(this.client);

  /// `GET /organizations/{organizationId}/iot-devices` — the org's IoT devices
  /// wrapped with the subscription quota: `{devices: [...], quota: {used, limit}}`.
  /// A bare list (older deployments) is still accepted.
  Future<DeviceListDto> getDevices(String organizationId) async {
    final data = await client.getJson(
      '/organizations/$organizationId/iot-devices',
    );

    if (data is List) {
      return DeviceListDto(
        devices: data.cast<JSON>().map(IotDeviceDto.fromJson).toList(),
      );
    }

    final json = data as JSON;
    final list = (json['devices'] as List? ?? const []).cast<JSON>();
    final quota = json['quota'] as JSON?;
    return DeviceListDto(
      devices: list.map(IotDeviceDto.fromJson).toList(),
      quotaUsed: (quota?['used'] as num?)?.toInt(),
      quotaLimit: (quota?['limit'] as num?)?.toInt(),
    );
  }

  /// `GET /iot-devices/{id}` — a single device. Authorization is resolved by
  /// the backend from the device's owning organization.
  Future<IotDeviceDto> getDevice(String deviceId) async {
    final data = await client.getJson('/iot-devices/$deviceId');
    return IotDeviceDto.fromJson(data as JSON);
  }

  /// `POST /organizations/{organizationId}/iot-devices` — claims a
  /// factory-provisioned device by its code into the organization. Omit
  /// [thresholds] to apply the backend's standard defaults.
  Future<IotDeviceDto> claimDevice(
    String organizationId, {
    required String code,
    required String name,
    JSON? thresholds,
  }) async {
    final data = await client.postJson(
      '/organizations/$organizationId/iot-devices',
      body: {'code': code, 'name': name, 'thresholds': ?thresholds},
    );
    return IotDeviceDto.fromJson(data as JSON);
  }

  /// `PATCH /iot-devices/{id}` — partial update of a claimed device. Only the
  /// provided fields travel in the body; omitted ones stay unchanged.
  Future<IotDeviceDto> updateDevice(
    String deviceId, {
    String? name,
    JSON? thresholds,
    String? status,
  }) async {
    final data = await client.patchJson(
      '/iot-devices/$deviceId',
      body: {
        'name': ?name,
        'thresholds': ?thresholds,
        'status': ?status,
      },
    );
    return IotDeviceDto.fromJson(data as JSON);
  }

  /// `GET /organizations/{organizationId}/edge-device` — the org's edge gateway.
  /// Returns `null` when the organization has no edge device yet (backend 404).
  Future<EdgeDeviceDto?> getEdgeDevice(String organizationId) async {
    try {
      final data = await client.getJson(
        '/organizations/$organizationId/edge-device',
      );
      return EdgeDeviceDto.fromJson(data as JSON);
    } on ApiGatewayException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  /// `POST /organizations/{organizationId}/edge-device` — claims a
  /// factory-provisioned edge gateway by its code into the organization. An
  /// organization has at most one edge device.
  Future<EdgeDeviceDto> claimEdgeDevice(
    String organizationId, {
    required String code,
    required String name,
  }) async {
    final data = await client.postJson(
      '/organizations/$organizationId/edge-device',
      body: {'code': code, 'name': name},
    );
    return EdgeDeviceDto.fromJson(data as JSON);
  }
}
