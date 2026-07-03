import 'package:cocina360/features/organization/domain/model/member_role.dart';
import 'package:cocina360/features/organization/domain/model/organization_member.dart';
import 'package:cocina360/shared/data/types/json.dart';

/// Maps an enriched member item from
/// `GET /organizations/{id}/members` (served through the api-gw).
///
/// Wire shape (`OrganizationMemberResponse`): permission levels are nested
/// under `permissions: {security, organizations, internalControl}`, and the
/// profile's id is `profile.id` (a `ProfileSummary`), not `profile.profileId`.
class OrganizationMemberDto {
  final String id;
  final String profileId;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String? securityPermission;
  final String? organizationPermission;
  final String? internalControlPermission;

  const OrganizationMemberDto({
    required this.id,
    required this.profileId,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    this.securityPermission,
    this.organizationPermission,
    this.internalControlPermission,
  });

  factory OrganizationMemberDto.fromJson(JSON json) {
    // The backend embeds the member's profile under `profile` (a ProfileSummary)
    // and its permission levels under `permissions`.
    final profile = (json['profile'] as JSON?) ?? const {};
    final permissions = (json['permissions'] as JSON?) ?? const {};

    return OrganizationMemberDto(
      id: json['id'] as String,
      profileId: (profile['id'] as String?) ?? '',
      fullName: (profile['fullName'] as String?) ?? '',
      email: (profile['email'] as String?) ?? '',
      avatarUrl: profile['avatarUrl'] as String?,
      securityPermission: permissions['security'] as String?,
      organizationPermission: permissions['organizations'] as String?,
      internalControlPermission: permissions['internalControl'] as String?,
    );
  }

  OrganizationMember toDomain() {
    final security = memberRoleFromString(securityPermission);
    final organization = memberRoleFromString(organizationPermission);
    final internalControl = memberRoleFromString(internalControlPermission);

    return OrganizationMember(
      id: id,
      profileId: profileId,
      fullName: fullName,
      email: email,
      avatarUrl: avatarUrl,
      security: security,
      organization: organization,
      internalControl: internalControl,
      role: highestRole([security, organization, internalControl]),
    );
  }
}
