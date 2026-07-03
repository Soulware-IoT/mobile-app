import 'package:cocina360/features/organization/domain/model/member_role.dart';
import 'package:cocina360/shared/data/types/json.dart';

/// Body for `PUT /organizations/{id}/members/{memberId}/permissions`
/// (backend `UpdateMemberPermissionsRequest`). All three contexts are required;
/// values are the uppercase `PermissionLevel` enum.
class UpdateMemberPermissionsRequest {
  final MemberRole security;
  final MemberRole organization;
  final MemberRole internalControl;

  const UpdateMemberPermissionsRequest({
    required this.security,
    required this.organization,
    required this.internalControl,
  });

  JSON toJson() => {
    'security': security.apiValue,
    'organizations': organization.apiValue,
    'internalControl': internalControl.apiValue,
  };
}
