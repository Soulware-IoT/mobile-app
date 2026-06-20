import 'package:cocina360/features/organization/domain/model/invitation.dart';
import 'package:cocina360/features/organization/domain/model/member_role.dart';
import 'package:cocina360/features/organization/domain/model/organization.dart';
import 'package:cocina360/features/organization/domain/model/organization_member.dart';

/// An organization together with its members, as shown on the Organization
/// screen.
class OrganizationWithMembers {
  final Organization organization;
  final List<OrganizationMember> members;

  const OrganizationWithMembers(this.organization, this.members);
}

abstract class OrganizationRepository {
  /// Returns the user's primary organization with its members, or `null` when
  /// the user does not belong to any organization yet.
  Future<OrganizationWithMembers?> getPrimaryOrganization(String userId);

  /// Updates the organization's editable details and returns the new state.
  Future<Organization> updateOrganization({
    required String organizationId,
    required String name,
    String? imageUrl,
    String? addressLineOne,
    String? addressLineTwo,
    String? addressReference,
  });

  /// Updates a member's per-context permissions and returns the new member.
  Future<OrganizationMember> updateMemberPermissions({
    required String organizationId,
    required String memberId,
    required MemberRole security,
    required MemberRole iot,
    required MemberRole internalControl,
  });

  /// Invites a member to the organization by email.
  Future<void> inviteMember({
    required String organizationId,
    required String email,
  });

  /// Returns the organization's invitations.
  Future<List<Invitation>> getInvitations(String organizationId);

  /// Returns the invitations addressed to the given profile (current user).
  Future<List<Invitation>> getMyInvitations(String profileId);

  /// Accepts an invitation (the current user becomes a member).
  Future<void> acceptInvitation(String invitationId);

  /// Declines an invitation.
  Future<void> declineInvitation(String invitationId);
}
