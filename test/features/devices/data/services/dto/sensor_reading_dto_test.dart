import 'package:flutter_test/flutter_test.dart';
import 'package:cocina360/features/devices/data/services/dto/sensor_reading_dto.dart';
import 'package:cocina360/features/devices/domain/model/reading_severity.dart';

void main() {
  test('mapea el payload completo del evento reading', () {
    final dto = SensorReadingDto.fromJson({
      'id': 'r-1',
      'deviceId': 'd-1',
      'deviceCode': 'COCINA-XYZ',
      'temperatureC': 29,
      'gasPpm': 814.7,
      'severity': 'warning',
      'occurredAt': '2026-07-08T17:25:00Z',
      'recordedAt': '2026-07-08T17:25:01Z',
    });

    final reading = dto.toDomain();

    expect(reading.id, 'r-1');
    expect(reading.deviceId, 'd-1');
    expect(reading.deviceCode, 'COCINA-XYZ');
    expect(reading.temperatureC, 29);
    expect(reading.gasPpm, 814.7);
    expect(reading.severity, ReadingSeverity.warning);
    expect(reading.occurredAt, DateTime.parse('2026-07-08T17:25:00Z'));
    expect(reading.recordedAt, DateTime.parse('2026-07-08T17:25:01Z'));
  });

  test('coerciona numéricos cruzados (int como double y viceversa)', () {
    final dto = SensorReadingDto.fromJson({
      'id': 'r-2',
      'deviceId': 'd-1',
      'deviceCode': 'C',
      'temperatureC': 29.0, // double en el wire → int en dominio
      'gasPpm': 800, // int en el wire → double en dominio
      'severity': 'safe',
    });

    final reading = dto.toDomain();

    expect(reading.temperatureC, 29);
    expect(reading.gasPpm, 800.0);
  });

  test('severity desconocida o ausente cae en safe', () {
    expect(
      SensorReadingDto.fromJson({'severity': 'bogus'}).toDomain().severity,
      ReadingSeverity.safe,
    );
    expect(
      SensorReadingDto.fromJson(const {}).toDomain().severity,
      ReadingSeverity.safe,
    );
  });

  test('fechas inválidas quedan en null sin lanzar', () {
    final reading = SensorReadingDto.fromJson({
      'occurredAt': 'not-a-date',
    }).toDomain();

    expect(reading.occurredAt, isNull);
    expect(reading.recordedAt, isNull);
  });
}
