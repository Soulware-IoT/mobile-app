/// Whether the presence record belongs to the edge gateway or an IoT sensor.
enum DevicePresenceKind { edge, iot }

/// Ephemeral online/offline signal for a device, from the presence snapshot
/// and SSE stream. Separate from the device lifecycle status
/// (provisioned/active/inactive) — this is live connectivity.
class DevicePresence {
  final String deviceId;
  final String deviceCode;
  final DevicePresenceKind kind;
  final bool online;

  /// Last-seen timestamp reported by the backend.
  final DateTime? since;

  const DevicePresence({
    required this.deviceId,
    required this.deviceCode,
    required this.kind,
    required this.online,
    this.since,
  });
}
