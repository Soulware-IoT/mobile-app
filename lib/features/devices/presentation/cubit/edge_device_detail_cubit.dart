import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cocina360/features/devices/domain/repositories/device_repository.dart';
import 'package:cocina360/features/devices/presentation/cubit/edge_device_detail_state.dart';

/// There is no `GET /edge-device/{id}`, only the organization-scoped
/// `GET /organizations/{id}/edge-device` — so, unlike the IoT device detail
/// cubit, this refreshes by organization id rather than by the edge
/// device's own id.
class EdgeDeviceDetailCubit extends Cubit<EdgeDeviceDetailState> {
  final DeviceRepository repository;

  EdgeDeviceDetailCubit(this.repository) : super(const EdgeDeviceDetailInitial());

  Future<void> load(String organizationId) async {
    emit(const EdgeDeviceDetailLoading());
    try {
      final device = await repository.getEdgeDevice(organizationId);
      if (device == null) {
        emit(EdgeDeviceDetailError(StateError('Edge device not found')));
        return;
      }
      emit(EdgeDeviceDetailLoaded(device));
    } catch (e) {
      emit(EdgeDeviceDetailError(e));
    }
  }

  /// Activates or deactivates the edge device (`PATCH status`).
  Future<void> setActive(bool active) => _update(active: active);

  /// Renames the edge device (`PATCH name`).
  Future<void> rename(String name) => _update(name: name);

  Future<void> _update({String? name, bool? active}) async {
    final current = state;
    if (current is! EdgeDeviceDetailLoaded || current.updating) return;

    emit(EdgeDeviceDetailLoaded(current.device, updating: true));
    try {
      final updated = await repository.updateEdgeDevice(
        current.device.edgeDeviceId,
        name: name,
        active: active,
      );
      emit(EdgeDeviceDetailLoaded(updated));
    } catch (e) {
      // Keep the last known device on screen; the page shows the error.
      emit(EdgeDeviceDetailLoaded(current.device, updateError: e));
    }
  }
}
