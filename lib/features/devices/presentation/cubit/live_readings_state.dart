import 'package:cocina360/features/devices/domain/model/device_presence.dart';
import 'package:cocina360/features/devices/domain/model/sensor_reading.dart';

/// Lifecycle of one SSE connection as UI state (mirrors the web app's
/// idle/connecting/live/reconnecting indicator).
enum StreamStatus { connecting, live, reconnecting }

sealed class LiveReadingsState {
  const LiveReadingsState();
}

final class LiveReadingsInitial extends LiveReadingsState {
  const LiveReadingsInitial();
}

final class LiveReadingsConnecting extends LiveReadingsState {
  const LiveReadingsConnecting();
}

/// Fatal setup failure only (missing gateway URL, snapshot 401/403). Stream
/// drops after setup never land here — they show as [StreamStatus.reconnecting]
/// inside [LiveReadingsActive].
final class LiveReadingsError extends LiveReadingsState {
  final Object error;

  const LiveReadingsError(this.error);
}

final class LiveReadingsActive extends LiveReadingsState {
  final StreamStatus readingsStatus;
  final StreamStatus presenceStatus;
  final String? selectedDeviceId;

  /// Rolling window of readings per device id, oldest first, capped at 120.
  final Map<String, List<SensorReading>> historyByDevice;
  final Map<String, SensorReading> latestByDevice;
  final Map<String, DevicePresence> presenceByDevice;

  const LiveReadingsActive({
    required this.readingsStatus,
    required this.presenceStatus,
    this.selectedDeviceId,
    this.historyByDevice = const {},
    this.latestByDevice = const {},
    this.presenceByDevice = const {},
  });

  bool get reconnecting =>
      readingsStatus == StreamStatus.reconnecting ||
      presenceStatus == StreamStatus.reconnecting;

  LiveReadingsActive copyWith({
    StreamStatus? readingsStatus,
    StreamStatus? presenceStatus,
    String? selectedDeviceId,
    Map<String, List<SensorReading>>? historyByDevice,
    Map<String, SensorReading>? latestByDevice,
    Map<String, DevicePresence>? presenceByDevice,
  }) {
    return LiveReadingsActive(
      readingsStatus: readingsStatus ?? this.readingsStatus,
      presenceStatus: presenceStatus ?? this.presenceStatus,
      selectedDeviceId: selectedDeviceId ?? this.selectedDeviceId,
      historyByDevice: historyByDevice ?? this.historyByDevice,
      latestByDevice: latestByDevice ?? this.latestByDevice,
      presenceByDevice: presenceByDevice ?? this.presenceByDevice,
    );
  }
}
