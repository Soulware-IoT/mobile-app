import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cocina360/features/devices/domain/repositories/device_repository.dart';
import 'package:cocina360/features/devices/presentation/cubit/claim_edge_device_state.dart';

class ClaimEdgeDeviceCubit extends Cubit<ClaimEdgeDeviceState> {
  final DeviceRepository repository;

  ClaimEdgeDeviceCubit(this.repository) : super(const ClaimEdgeDeviceInitial());

  Future<void> claim({
    required String organizationId,
    required String code,
    required String name,
  }) async {
    emit(const ClaimEdgeDeviceClaiming());
    try {
      final device = await repository.claimEdgeDevice(
        organizationId: organizationId,
        code: code,
        name: name,
      );
      emit(ClaimEdgeDeviceSuccess(device));
    } catch (e) {
      emit(ClaimEdgeDeviceFailure(e));
    }
  }
}
