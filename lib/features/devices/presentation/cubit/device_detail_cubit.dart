import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cocina360/features/devices/domain/repositories/device_repository.dart';
import 'package:cocina360/features/devices/presentation/cubit/device_detail_state.dart';

class DeviceDetailCubit extends Cubit<DeviceDetailState> {
  final DeviceRepository repository;

  DeviceDetailCubit(this.repository) : super(const DeviceDetailInitial());

  Future<void> load(String organizationId, String deviceId) async {
    emit(const DeviceDetailLoading());
    try {
      final device = await repository.getDevice(organizationId, deviceId);
      emit(DeviceDetailLoaded(device));
    } catch (e) {
      emit(DeviceDetailError(e));
    }
  }
}
