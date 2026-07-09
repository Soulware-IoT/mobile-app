import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cocina360/features/devices/domain/model/device_presence.dart';
import 'package:cocina360/features/devices/domain/model/sensor_reading.dart';
import 'package:cocina360/features/devices/domain/repositories/telemetry_repository.dart';
import 'package:cocina360/features/devices/presentation/cubit/live_readings_state.dart';
import 'package:cocina360/shared/infrastructure/remote/api_gateway_client.dart';

/// Drives the Live Readings page: subscribes to the readings and presence SSE
/// streams and owns their reconnection loop (5s backoff, like the web app).
/// The repository streams are single connection attempts, so each retry here
/// re-resolves headers — picking up a refreshed Supabase token for free.
class LiveReadingsCubit extends Cubit<LiveReadingsState> {
  static const historyLimit = 120;
  static const retryDelay = Duration(seconds: 5);

  final TelemetryRepository repository;

  String? _organizationId;
  StreamSubscription<SensorReading>? _readingsSub;
  StreamSubscription<DevicePresence>? _presenceSub;
  Timer? _readingsRetry;
  Timer? _presenceRetry;

  LiveReadingsCubit(this.repository) : super(const LiveReadingsInitial());

  Future<void> start(String organizationId) async {
    _organizationId = organizationId;
    emit(const LiveReadingsConnecting());

    // Snapshot failures degrade gracefully (empty presence, dots show "no
    // signal") — except auth/setup failures, which are fatal for the page.
    Map<String, DevicePresence> initialPresence = const {};
    try {
      final snapshot = await repository.presenceSnapshot(organizationId);
      initialPresence = {for (final p in snapshot) p.deviceId: p};
    } catch (e) {
      if (isClosed) return;
      if (_isFatal(e)) {
        emit(LiveReadingsError(e));
        return;
      }
    }
    if (isClosed) return;

    emit(
      LiveReadingsActive(
        readingsStatus: StreamStatus.connecting,
        presenceStatus: StreamStatus.connecting,
        presenceByDevice: initialPresence,
      ),
    );
    _subscribeReadings();
    _subscribePresence();
  }

  void selectDevice(String deviceId) {
    final current = state;
    if (current is! LiveReadingsActive) return;
    emit(current.copyWith(selectedDeviceId: deviceId));
  }

  void _subscribeReadings() {
    final organizationId = _organizationId;
    if (organizationId == null || isClosed) return;

    _readingsSub?.cancel();
    _readingsSub = repository
        .readings(organizationId)
        .listen(
          _onReading,
          onError: (Object _) => _scheduleReadingsRetry(),
          onDone: _scheduleReadingsRetry,
          cancelOnError: true,
        );
  }

  void _subscribePresence() {
    final organizationId = _organizationId;
    if (organizationId == null || isClosed) return;

    _presenceSub?.cancel();
    _presenceSub = repository
        .presence(organizationId)
        .listen(
          _onPresence,
          onError: (Object _) => _schedulePresenceRetry(),
          onDone: _schedulePresenceRetry,
          cancelOnError: true,
        );
  }

  void _onReading(SensorReading reading) {
    final current = state;
    if (current is! LiveReadingsActive) return;

    final history = List<SensorReading>.of(
      current.historyByDevice[reading.deviceId] ?? const [],
    )..add(reading);
    if (history.length > historyLimit) {
      history.removeRange(0, history.length - historyLimit);
    }

    emit(
      current.copyWith(
        readingsStatus: StreamStatus.live,
        historyByDevice: {
          ...current.historyByDevice,
          reading.deviceId: history,
        },
        latestByDevice: {...current.latestByDevice, reading.deviceId: reading},
      ),
    );
  }

  void _onPresence(DevicePresence presence) {
    final current = state;
    if (current is! LiveReadingsActive) return;

    emit(
      current.copyWith(
        presenceStatus: StreamStatus.live,
        presenceByDevice: {
          ...current.presenceByDevice,
          presence.deviceId: presence,
        },
      ),
    );
  }

  void _scheduleReadingsRetry() {
    if (isClosed) return;
    final current = state;
    if (current is LiveReadingsActive) {
      emit(current.copyWith(readingsStatus: StreamStatus.reconnecting));
    }
    _readingsRetry?.cancel();
    _readingsRetry = Timer(retryDelay, _subscribeReadings);
  }

  void _schedulePresenceRetry() {
    if (isClosed) return;
    final current = state;
    if (current is LiveReadingsActive) {
      emit(current.copyWith(presenceStatus: StreamStatus.reconnecting));
    }
    _presenceRetry?.cancel();
    _presenceRetry = Timer(retryDelay, _subscribePresence);
  }

  /// Auth failures mean the whole page is off-limits (backend requires
  /// SECURITY/ASSIGNEE); anything else is a transient network condition.
  bool _isFatal(Object error) =>
      error is ApiGatewayException &&
      (error.statusCode == 401 || error.statusCode == 403);

  @override
  Future<void> close() {
    _readingsSub?.cancel();
    _presenceSub?.cancel();
    _readingsRetry?.cancel();
    _presenceRetry?.cancel();
    return super.close();
  }
}
