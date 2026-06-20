import 'package:cocina360/features/organization/domain/model/organization_member.dart';

sealed class EditMemberPermissionsState {
  const EditMemberPermissionsState();
}

final class EditMemberPermissionsInitial extends EditMemberPermissionsState {
  const EditMemberPermissionsInitial();
}

final class EditMemberPermissionsSaving extends EditMemberPermissionsState {
  const EditMemberPermissionsSaving();
}

final class EditMemberPermissionsSuccess extends EditMemberPermissionsState {
  final OrganizationMember member;

  const EditMemberPermissionsSuccess(this.member);
}

final class EditMemberPermissionsFailure extends EditMemberPermissionsState {
  final Object error;

  const EditMemberPermissionsFailure(this.error);
}
