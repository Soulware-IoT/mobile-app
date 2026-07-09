import 'package:cocina360/features/devices/data/services/dto/device_presence_dto.dart';
import 'package:cocina360/features/devices/data/services/dto/sensor_reading_dto.dart';
import 'package:cocina360/shared/data/types/json.dart';
import 'package:cocina360/shared/infrastructure/remote/api_gateway_client.dart';
import 'package:cocina360/shared/infrastructure/remote/sse_client.dart';

/// Talks to the backend's telemetry endpoints (Security context) through the
/// api-gw: SSE streams via [SseClient], snapshot/commands via
/// [ApiGatewayClient].
class TelemetryRemoteService {
  final ApiGatewayClient client;
  final SseClient sse;

  TelemetryRemoteService(this.client, this.sse);

  /// SSE `GET /organizations/{organizationId}/readings/stream`
  Stream<SensorReadingDto> readingStream(String organizationId) {
    return sse
        .events('/organizations/$organizationId/readings/stream',
            eventName: 'reading')
        .map((event) => SensorReadingDto.fromJson(event.data));
  }

  /// SSE `GET /organizations/{organizationId}/devices/presence/stream`
  Stream<DevicePresenceDto> presenceStream(String organizationId) {
    return sse
        .events('/organizations/$organizationId/devices/presence/stream',
            eventName: 'presence')
        .map((event) => DevicePresenceDto.fromJson(event.data));
  }

  /// `GET /organizations/{organizationId}/devices/presence`
  Future<List<DevicePresenceDto>> presenceSnapshot(
    String organizationId,
  ) async {
    final data = await client.getJson(
      '/organizations/$organizationId/devices/presence',
    );
    return (data as List<dynamic>)
        .map((item) => DevicePresenceDto.fromJson(item as JSON))
        .toList();
  }

  /// `POST /iot-devices/{id}/servo`
  Future<void> sendServo(String deviceId, String command) async {
    await client.postJson(
      '/iot-devices/$deviceId/servo',
      body: {'command': command},
    );
  }
}
