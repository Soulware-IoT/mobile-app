import 'package:cocina360/features/devices/data/services/dto/edge_device_dto.dart';
import 'package:cocina360/features/devices/data/services/dto/iot_device_dto.dart';
import 'package:cocina360/shared/data/types/json.dart';
import 'package:cocina360/shared/infrastructure/remote/api_gateway_client.dart';

/// Reads device data from the backend through the api-gw (read-only endpoints).
class DeviceRemoteService {
  final ApiGatewayClient client;

  DeviceRemoteService(this.client);

  /// `GET /organizations/{organizationId}/iot-devices` — the org's IoT devices.
  Future<List<IotDeviceDto>> getDevices(String organizationId) async {
    final data = await client.getJson(
      '/organizations/$organizationId/iot-devices',
    );
    final list = (data as List).cast<JSON>();
    return list.map(IotDeviceDto.fromJson).toList();
  }

  /// `GET /iot-devices/{id}` — a single device. The gateway guard needs the
  /// organization in the query since it is not in the path.
  Future<IotDeviceDto> getDevice(
    String organizationId,
    String deviceId,
  ) async {
    final data = await client.getJson(
      '/iot-devices/$deviceId',
      query: {'organizationId': organizationId},
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
}
