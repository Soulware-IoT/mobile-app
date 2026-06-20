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
}
