import 'package:cocina360/features/devices/domain/model/device_presence.dart';
import 'package:cocina360/shared/data/types/json.dart';

/// Maps the backend `DevicePresenceResponse` (snapshot item and SSE
/// `presence` event payload) into the [DevicePresence] domain model.
class DevicePresenceDto {
  final String deviceId;
  final String deviceCode;
  final String? kind;
  final String? status;
  final String? since;

  const DevicePresenceDto({
    required this.deviceId,
    required this.deviceCode,
    this.kind,
    this.status,
    this.since,
  });

  factory DevicePresenceDto.fromJson(JSON json) {
    return DevicePresenceDto(
      deviceId: json['deviceId'] as String? ?? '',
      deviceCode: json['deviceCode'] as String? ?? '',
      kind: json['kind'] as String?,
      status: json['status'] as String?,
      since: json['since'] as String?,
    );
  }

  DevicePresence toDomain() {
    return DevicePresence(
      deviceId: deviceId,
      deviceCode: deviceCode,
      kind: kind?.toLowerCase() == 'edge'
          ? DevicePresenceKind.edge
          : DevicePresenceKind.iot,
      online: status?.toLowerCase() == 'online',
      since: since == null ? null : DateTime.tryParse(since!),
    );
  }
}
