import 'package:cocina360/features/devices/domain/model/reading_severity.dart';

/// A single sensor measurement pushed over the readings SSE stream.
class SensorReading {
  final String id;
  final String deviceId;
  final String deviceCode;
  final int temperatureC;
  final double gasPpm;
  final ReadingSeverity severity;

  /// When the reading happened at the device.
  final DateTime? occurredAt;

  /// When the backend persisted it.
  final DateTime? recordedAt;

  const SensorReading({
    required this.id,
    required this.deviceId,
    required this.deviceCode,
    required this.temperatureC,
    required this.gasPpm,
    required this.severity,
    required this.occurredAt,
    required this.recordedAt,
  });
}
