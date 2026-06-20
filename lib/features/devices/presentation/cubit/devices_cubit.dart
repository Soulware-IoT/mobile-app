import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cocina360/features/devices/domain/model/edge_device.dart';
import 'package:cocina360/features/devices/domain/repositories/device_repository.dart';
import 'package:cocina360/features/devices/presentation/cubit/devices_state.dart';

class DevicesCubit extends Cubit<DevicesState> {
  final DeviceRepository repository;

  DevicesCubit(this.repository) : super(const DevicesInitial());

  Future<void> load(String organizationId) async {
    emit(const DevicesLoading());
    try {
      final devices = await repository.getDevices(organizationId);
      // The edge gateway is supplementary: a failure there must not blank the
      // whole screen, so it degrades to null.
      EdgeDevice? edge;
      try {
        edge = await repository.getEdgeDevice(organizationId);
      } catch (_) {
        edge = null;
      }
      emit(DevicesLoaded(devices, edge));
    } catch (e) {
      emit(DevicesError(e));
    }
  }
}
