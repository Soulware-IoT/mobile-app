import 'package:cocina360/features/devices/domain/model/device_presence.dart';
import 'package:cocina360/features/devices/domain/model/sensor_reading.dart';

/// Physical actuation command relayed to the device's servo through the edge.
enum ServoCommand { start, stop }

extension ServoCommandX on ServoCommand {
  /// Wire value expected by the backend (lowercase in the REST contract).
  String get apiValue => name;
}

/// Live telemetry for an organization's devices: readings and presence over
/// SSE, plus the servo actuation command.
abstract class TelemetryRepository {
  /// Live sensor readings. One connection attempt per listen: the stream
  /// errors/completes when the connection drops — callers own reconnection.
  Stream<SensorReading> readings(String organizationId);

  /// Live presence transitions (online/offline). Same single-attempt
  /// semantics as [readings].
  Stream<DevicePresence> presence(String organizationId);

  /// Point-in-time presence for all the organization's devices (devices that
  /// never connected are reported offline).
  Future<List<DevicePresence>> presenceSnapshot(String organizationId);

  /// Sends a start/stop command to the device's servo via the edge gateway.
  Future<void> sendServoCommand(String deviceId, ServoCommand command);
}
