import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cocina360/features/devices/domain/model/thresholds.dart';
import 'package:cocina360/features/devices/domain/repositories/device_repository.dart';
import 'package:cocina360/features/devices/presentation/cubit/device_detail_state.dart';

class DeviceDetailCubit extends Cubit<DeviceDetailState> {
  final DeviceRepository repository;

  DeviceDetailCubit(this.repository) : super(const DeviceDetailInitial());

  Future<void> load(String deviceId) async {
    emit(const DeviceDetailLoading());
    try {
      final device = await repository.getDevice(deviceId);
      emit(DeviceDetailLoaded(device));
    } catch (e) {
      emit(DeviceDetailError(e));
    }
  }

  /// Activates or deactivates the device (`PATCH status`).
  Future<void> setActive(String deviceId, bool active) =>
      _update(deviceId, active: active);

  /// Renames the device (`PATCH name`).
  Future<void> rename(String deviceId, String name) =>
      _update(deviceId, name: name);

  /// Replaces the calibration thresholds (`PATCH thresholds`).
  Future<void> updateThresholds(String deviceId, Thresholds thresholds) =>
      _update(deviceId, thresholds: thresholds);

  Future<void> _update(
    String deviceId, {
    String? name,
    Thresholds? thresholds,
    bool? active,
  }) async {
    final current = state;
    if (current is! DeviceDetailLoaded || current.updating) return;

    emit(DeviceDetailLoaded(current.device, updating: true));
    try {
      final updated = await repository.updateDevice(
        deviceId,
        name: name,
        thresholds: thresholds,
        active: active,
      );
      emit(DeviceDetailLoaded(updated));
    } catch (e) {
      // Keep the last known device on screen; the page shows the error.
      emit(DeviceDetailLoaded(current.device, updateError: e));
    }
  }
}
