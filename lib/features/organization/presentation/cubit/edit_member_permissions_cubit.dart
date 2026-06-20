import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cocina360/features/organization/domain/model/member_role.dart';
import 'package:cocina360/features/organization/domain/repositories/organization_repository.dart';
import 'package:cocina360/features/organization/presentation/cubit/edit_member_permissions_state.dart';

class EditMemberPermissionsCubit extends Cubit<EditMemberPermissionsState> {
  final OrganizationRepository repository;

  EditMemberPermissionsCubit(this.repository)
    : super(const EditMemberPermissionsInitial());

  Future<void> save({
    required String organizationId,
    required String memberId,
    required MemberRole security,
    required MemberRole iot,
    required MemberRole internalControl,
  }) async {
    emit(const EditMemberPermissionsSaving());
    try {
      final member = await repository.updateMemberPermissions(
        organizationId: organizationId,
        memberId: memberId,
        security: security,
        iot: iot,
        internalControl: internalControl,
      );
      emit(EditMemberPermissionsSuccess(member));
    } catch (e) {
      emit(EditMemberPermissionsFailure(e.toString()));
    }
  }
}
