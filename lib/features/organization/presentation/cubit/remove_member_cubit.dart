import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cocina360/features/organization/domain/repositories/organization_repository.dart';
import 'package:cocina360/features/organization/presentation/cubit/remove_member_state.dart';

class RemoveMemberCubit extends Cubit<RemoveMemberState> {
  final OrganizationRepository repository;

  RemoveMemberCubit(this.repository) : super(const RemoveMemberInitial());

  Future<void> remove({
    required String organizationId,
    required String memberId,
  }) async {
    emit(const RemoveMemberRemoving());
    try {
      await repository.removeMember(
        organizationId: organizationId,
        memberId: memberId,
      );
      emit(const RemoveMemberSuccess());
    } catch (e) {
      emit(RemoveMemberFailure(e));
    }
  }
}
