import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cocina360/features/organization/domain/repositories/organization_repository.dart';
import 'package:cocina360/features/organization/presentation/cubit/invite_member_state.dart';

class InviteMemberCubit extends Cubit<InviteMemberState> {
  final OrganizationRepository repository;

  InviteMemberCubit(this.repository) : super(const InviteMemberInitial());

  Future<void> invite({
    required String organizationId,
    required String email,
  }) async {
    emit(const InviteMemberSending());
    try {
      await repository.inviteMember(
        organizationId: organizationId,
        email: email,
      );
      emit(const InviteMemberSuccess());
    } catch (e) {
      emit(InviteMemberFailure(e));
    }
  }
}
