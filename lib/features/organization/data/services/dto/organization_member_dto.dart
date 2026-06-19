import 'package:cocina360/features/organization/domain/model/member_role.dart';
import 'package:cocina360/features/organization/domain/model/organization_member.dart';
import 'package:cocina360/shared/data/types/json.dart';

/// Maps an enriched member item from
/// `GET /organizations/{id}/members` (served through the api-gw).
///
/// Beyond the existing `OrganizationMemberResponse` fields, this expects the
/// backend to embed the member's profile (`fullName`, `email`, `avatarUrl`) so
/// the list can render without an N+1 profile fetch — see docs/backend-contract.md.
class OrganizationMemberDto {
  final String id;
  final String profileId;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String? securityPermission;
  final String? iotPermission;
  final String? internalControlPermission;

  const OrganizationMemberDto({
    required this.id,
    required this.profileId,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    this.securityPermission,
    this.iotPermission,
    this.internalControlPermission,
  });

  factory OrganizationMemberDto.fromJson(JSON json) {
    // The backend embeds the member's profile under `profile` (a ProfileSummary).
    final profile = (json['profile'] as JSON?) ?? const {};

    return OrganizationMemberDto(
      id: json['id'] as String,
      profileId: (profile['profileId'] as String?) ?? '',
      fullName: (profile['fullName'] as String?) ?? '',
      email: (profile['email'] as String?) ?? '',
      avatarUrl: profile['avatarUrl'] as String?,
      securityPermission: json['securityPermission'] as String?,
      iotPermission: json['iotPermission'] as String?,
      internalControlPermission: json['internalControlPermission'] as String?,
    );
  }

  OrganizationMember toDomain() {
    final role = highestRole([
      memberRoleFromString(securityPermission),
      memberRoleFromString(iotPermission),
      memberRoleFromString(internalControlPermission),
    ]);

    return OrganizationMember(
      id: id,
      profileId: profileId,
      fullName: fullName,
      email: email,
      avatarUrl: avatarUrl,
      role: role,
    );
  }
}
