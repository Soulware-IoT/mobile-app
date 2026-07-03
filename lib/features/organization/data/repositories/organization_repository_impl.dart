import 'package:cocina360/features/organization/data/services/dto/update_member_permissions_request.dart';
import 'package:cocina360/features/organization/data/services/dto/update_organization_request.dart';
import 'package:cocina360/features/organization/data/services/organization_remote_service.dart';
import 'package:cocina360/features/organization/domain/model/invitation.dart';
import 'package:cocina360/features/organization/domain/model/member_role.dart';
import 'package:cocina360/features/organization/domain/model/organization.dart';
import 'package:cocina360/features/organization/domain/model/organization_member.dart';
import 'package:cocina360/features/organization/domain/repositories/organization_repository.dart';
import 'package:cocina360/shared/infrastructure/network/network_checker.dart';
import 'package:cocina360/shared/infrastructure/network/no_connection_exception.dart';
import 'package:cocina360/shared/infrastructure/remote/session_claims.dart';

class OrganizationRepositoryImpl implements OrganizationRepository {
  final OrganizationRemoteService remoteService;
  final SessionClaims sessionClaims;
  final NetworkChecker connectionChecker;

  OrganizationRepositoryImpl(
    this.remoteService,
    this.sessionClaims,
    this.connectionChecker,
  );

  @override
  Future<OrganizationWithMembers?> getPrimaryOrganization(String userId) async {
    final online = await connectionChecker.isConnected;
    if (!online) {
      throw const NoConnectionException();
    }

    // The backend has no "list my organizations" endpoint — memberships come
    // from the JWT. The mockup shows a single org; pick the first membership as
    // the user's primary org. A switcher can be added later if needed.
    final memberships = sessionClaims.organizations();
    if (memberships.isEmpty) return null;

    return getOrganizationWithMembers(memberships.first.organizationId);
  }

  @override
  Future<OrganizationWithMembers> getOrganizationWithMembers(
    String organizationId,
  ) async {
    final online = await connectionChecker.isConnected;
    if (!online) {
      throw const NoConnectionException();
    }

    final organization =
        (await remoteService.getOrganization(organizationId)).toDomain();

    final memberDtos = await remoteService.getMembers(organizationId);
    final members = memberDtos.map((dto) => dto.toDomain()).toList();

    return OrganizationWithMembers(organization, members);
  }

  @override
  Future<List<Organization>> getMyOrganizations(String profileId) async {
    final online = await connectionChecker.isConnected;
    if (!online) {
      throw const NoConnectionException();
    }

    // Identity travels in the JWT; the profileId parameter is kept for the
    // domain interface but not sent over the wire.
    final dtos = await remoteService.getMyOrganizations();
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<Organization> updateOrganization({
    required String organizationId,
    required String name,
    String? imageUrl,
    String? addressLineOne,
    String? addressLineTwo,
    String? addressReference,
  }) async {
    final online = await connectionChecker.isConnected;
    if (!online) {
      throw const NoConnectionException();
    }

    final updated = await remoteService.updateOrganization(
      organizationId,
      UpdateOrganizationRequest(
        name: name,
        imageUrl: imageUrl,
        addressLineOne: addressLineOne,
        addressLineTwo: addressLineTwo,
        addressReference: addressReference,
      ),
    );

    return updated.toDomain();
  }

  @override
  Future<OrganizationMember> updateMemberPermissions({
    required String organizationId,
    required String memberId,
    required MemberRole security,
    required MemberRole organization,
    required MemberRole internalControl,
  }) async {
    final online = await connectionChecker.isConnected;
    if (!online) {
      throw const NoConnectionException();
    }

    final updated = await remoteService.updateMemberPermissions(
      organizationId,
      memberId,
      UpdateMemberPermissionsRequest(
        security: security,
        organization: organization,
        internalControl: internalControl,
      ),
    );

    return updated.toDomain();
  }

  @override
  Future<void> inviteMember({
    required String organizationId,
    required String email,
  }) async {
    final online = await connectionChecker.isConnected;
    if (!online) {
      throw const NoConnectionException();
    }

    await remoteService.inviteMember(organizationId, email);
  }

  @override
  Future<List<Invitation>> getInvitations(String organizationId) async {
    final online = await connectionChecker.isConnected;
    if (!online) {
      throw const NoConnectionException();
    }

    final dtos = await remoteService.getInvitations(organizationId);
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<List<Invitation>> getMyInvitations(String profileId) async {
    final online = await connectionChecker.isConnected;
    if (!online) {
      throw const NoConnectionException();
    }

    // Identity travels in the JWT; the profileId parameter is kept for the
    // domain interface but not sent over the wire.
    final dtos = await remoteService.getMyInvitations();
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<void> acceptInvitation(String invitationId) async {
    final online = await connectionChecker.isConnected;
    if (!online) {
      throw const NoConnectionException();
    }

    await remoteService.acceptInvitation(invitationId);
  }

  @override
  Future<void> declineInvitation(String invitationId) async {
    final online = await connectionChecker.isConnected;
    if (!online) {
      throw const NoConnectionException();
    }

    await remoteService.declineInvitation(invitationId);
  }
}
