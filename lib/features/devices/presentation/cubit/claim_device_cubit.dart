import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cocina360/features/devices/domain/model/thresholds.dart';
import 'package:cocina360/features/devices/domain/repositories/device_repository.dart';
import 'package:cocina360/features/devices/presentation/cubit/claim_device_state.dart';

class ClaimDeviceCubit extends Cubit<ClaimDeviceState> {
  final DeviceRepository repository;

  ClaimDeviceCubit(this.repository) : super(const ClaimDeviceInitial());

  Future<void> claim({
    required String organizationId,
    required String code,
    required String name,
    Thresholds? thresholds,
  }) async {
    emit(const ClaimDeviceClaiming());
    try {
      final device = await repository.claimDevice(
        organizationId: organizationId,
        code: code,
        name: name,
        thresholds: thresholds,
      );
      emit(ClaimDeviceSuccess(device));
    } catch (e) {
      emit(ClaimDeviceFailure(e));
    }
  }
}
