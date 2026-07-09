import 'package:cocina360/features/devices/domain/model/reading_severity.dart';
import 'package:cocina360/features/devices/domain/model/sensor_reading.dart';
import 'package:cocina360/shared/data/types/json.dart';

/// Maps the backend `ReadingStreamResponse` (SSE `reading` event payload)
/// into the [SensorReading] domain model.
class SensorReadingDto {
  final String id;
  final String deviceId;
  final String deviceCode;
  final int temperatureC;
  final double gasPpm;
  final String? severity;
  final String? occurredAt;
  final String? recordedAt;

  const SensorReadingDto({
    required this.id,
    required this.deviceId,
    required this.deviceCode,
    required this.temperatureC,
    required this.gasPpm,
    this.severity,
    this.occurredAt,
    this.recordedAt,
  });

  factory SensorReadingDto.fromJson(JSON json) {
    return SensorReadingDto(
      id: json['id'] as String? ?? '',
      deviceId: json['deviceId'] as String? ?? '',
      deviceCode: json['deviceCode'] as String? ?? '',
      // Tolerant numerics: JSON may carry ints as doubles and vice versa.
      temperatureC: (json['temperatureC'] as num?)?.toInt() ?? 0,
      gasPpm: (json['gasPpm'] as num?)?.toDouble() ?? 0,
      severity: json['severity'] as String?,
      occurredAt: json['occurredAt'] as String?,
      recordedAt: json['recordedAt'] as String?,
    );
  }

  SensorReading toDomain() {
    return SensorReading(
      id: id,
      deviceId: deviceId,
      deviceCode: deviceCode,
      temperatureC: temperatureC,
      gasPpm: gasPpm,
      severity: readingSeverityFromString(severity),
      occurredAt: occurredAt == null ? null : DateTime.tryParse(occurredAt!),
      recordedAt: recordedAt == null ? null : DateTime.tryParse(recordedAt!),
    );
  }
}
