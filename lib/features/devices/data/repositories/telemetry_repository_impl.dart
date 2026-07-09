import 'package:cocina360/features/devices/data/services/telemetry_remote_service.dart';
import 'package:cocina360/features/devices/domain/model/device_presence.dart';
import 'package:cocina360/features/devices/domain/model/sensor_reading.dart';
import 'package:cocina360/features/devices/domain/repositories/telemetry_repository.dart';
import 'package:cocina360/shared/infrastructure/network/network_checker.dart';
import 'package:cocina360/shared/infrastructure/network/no_connection_exception.dart';

class TelemetryRepositoryImpl implements TelemetryRepository {
  final TelemetryRemoteService remoteService;
  final NetworkChecker connectionChecker;

  TelemetryRepositoryImpl(this.remoteService, this.connectionChecker);

  // Streams don't pre-check connectivity: a dead network surfaces as a
  // connection error on the stream itself, which the cubit's reconnection
  // loop already handles.
  @override
  Stream<SensorReading> readings(String organizationId) =>
      remoteService.readingStream(organizationId).map((dto) => dto.toDomain());

  @override
  Stream<DevicePresence> presence(String organizationId) =>
      remoteService.presenceStream(organizationId).map((dto) => dto.toDomain());

  @override
  Future<List<DevicePresence>> presenceSnapshot(String organizationId) async {
    await _requireConnection();
    final dtos = await remoteService.presenceSnapshot(organizationId);
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<void> sendServoCommand(String deviceId, ServoCommand command) async {
    await _requireConnection();
    await remoteService.sendServo(deviceId, command.apiValue);
  }

  Future<void> _requireConnection() async {
    final online = await connectionChecker.isConnected;
    if (!online) {
      throw const NoConnectionException();
    }
  }
}
