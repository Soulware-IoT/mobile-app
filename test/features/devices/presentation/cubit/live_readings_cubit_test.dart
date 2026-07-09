import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cocina360/features/devices/domain/model/device_presence.dart';
import 'package:cocina360/features/devices/domain/model/reading_severity.dart';
import 'package:cocina360/features/devices/domain/model/sensor_reading.dart';
import 'package:cocina360/features/devices/domain/repositories/telemetry_repository.dart';
import 'package:cocina360/features/devices/presentation/cubit/live_readings_cubit.dart';
import 'package:cocina360/features/devices/presentation/cubit/live_readings_state.dart';
import 'package:cocina360/shared/infrastructure/remote/api_gateway_client.dart';

/// Fake repo driven by external StreamControllers; each subscribe attempt
/// gets a fresh controller so reconnection can be observed.
class FakeTelemetryRepository implements TelemetryRepository {
  final List<StreamController<SensorReading>> readingControllers = [];
  final List<StreamController<DevicePresence>> presenceControllers = [];
  List<DevicePresence> snapshot = const [];
  Object? snapshotError;

  @override
  Stream<SensorReading> readings(String organizationId) {
    final controller = StreamController<SensorReading>();
    readingControllers.add(controller);
    return controller.stream;
  }

  @override
  Stream<DevicePresence> presence(String organizationId) {
    final controller = StreamController<DevicePresence>();
    presenceControllers.add(controller);
    return controller.stream;
  }

  @override
  Future<List<DevicePresence>> presenceSnapshot(String organizationId) async {
    if (snapshotError != null) throw snapshotError!;
    return snapshot;
  }

  @override
  Future<void> sendServoCommand(String deviceId, ServoCommand command) async {}
}

SensorReading reading(String deviceId, {int temp = 25}) => SensorReading(
  id: 'r-$temp',
  deviceId: deviceId,
  deviceCode: 'CODE-$deviceId',
  temperatureC: temp,
  gasPpm: 500,
  severity: ReadingSeverity.safe,
  occurredAt: DateTime.utc(2026, 7, 8),
  recordedAt: DateTime.utc(2026, 7, 8),
);

DevicePresence presence(String deviceId, {bool online = true}) =>
    DevicePresence(
      deviceId: deviceId,
      deviceCode: 'CODE-$deviceId',
      kind: DevicePresenceKind.iot,
      online: online,
    );

void main() {
  late FakeTelemetryRepository repo;
  late LiveReadingsCubit cubit;

  setUp(() {
    repo = FakeTelemetryRepository();
    cubit = LiveReadingsCubit(repo);
  });

  tearDown(() => cubit.close());

  test('start: snapshot de presencia + ambos streams suscritos', () async {
    repo.snapshot = [presence('d1', online: true)];

    await cubit.start('org-1');

    final state = cubit.state as LiveReadingsActive;
    expect(state.presenceByDevice['d1']!.online, isTrue);
    expect(state.readingsStatus, StreamStatus.connecting);
    expect(repo.readingControllers, hasLength(1));
    expect(repo.presenceControllers, hasLength(1));
  });

  test('lecturas acumulan historia con tope 120 y actualizan latest', () async {
    await cubit.start('org-1');

    for (var i = 0; i < 130; i++) {
      repo.readingControllers.single.add(reading('d1', temp: i));
    }
    await Future<void>.delayed(Duration.zero);

    final state = cubit.state as LiveReadingsActive;
    expect(state.readingsStatus, StreamStatus.live);
    expect(state.historyByDevice['d1'], hasLength(120));
    expect(state.historyByDevice['d1']!.first.temperatureC, 10); // recortó los 10 primeros
    expect(state.latestByDevice['d1']!.temperatureC, 129);
  });

  test('evento de presencia mergea el mapa sin tocar otros devices', () async {
    repo.snapshot = [presence('d1', online: true)];
    await cubit.start('org-1');

    repo.presenceControllers.single.add(presence('d2', online: false));
    await Future<void>.delayed(Duration.zero);

    final state = cubit.state as LiveReadingsActive;
    expect(state.presenceByDevice['d1']!.online, isTrue);
    expect(state.presenceByDevice['d2']!.online, isFalse);
    expect(state.presenceStatus, StreamStatus.live);
  });

  test('caída del stream → reconnecting y re-suscripción tras 5s', () {
    fakeAsync((async) {
      cubit.start('org-1');
      async.flushMicrotasks();

      repo.readingControllers.single.addError(Exception('drop'));
      async.flushMicrotasks();

      var state = cubit.state as LiveReadingsActive;
      expect(state.readingsStatus, StreamStatus.reconnecting);
      expect(repo.readingControllers, hasLength(1));

      async.elapse(const Duration(seconds: 5));
      expect(repo.readingControllers, hasLength(2));

      repo.readingControllers.last.add(reading('d1'));
      async.flushMicrotasks();
      state = cubit.state as LiveReadingsActive;
      expect(state.readingsStatus, StreamStatus.live);
    });
  });

  test('snapshot 403 es fatal → LiveReadingsError', () async {
    repo.snapshotError = const ApiGatewayException(403, 'Prohibido');

    await cubit.start('org-1');

    expect(cubit.state, isA<LiveReadingsError>());
    expect(repo.readingControllers, isEmpty);
  });

  test('snapshot con error de red NO es fatal → Active con presencia vacía', () async {
    repo.snapshotError = Exception('network');

    await cubit.start('org-1');

    final state = cubit.state as LiveReadingsActive;
    expect(state.presenceByDevice, isEmpty);
    expect(repo.readingControllers, hasLength(1));
  });

  test('selectDevice fija el seleccionado', () async {
    await cubit.start('org-1');

    cubit.selectDevice('d9');

    expect((cubit.state as LiveReadingsActive).selectedDeviceId, 'd9');
  });
}

void fakeAsync(void Function(FakeAsync async) body) {
  FakeAsync().run(body);
}
