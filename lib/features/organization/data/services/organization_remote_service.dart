import 'package:cocina360/features/organization/data/services/dto/create_organization_request.dart';
import 'package:cocina360/features/organization/data/services/dto/invitation_dto.dart';
import 'package:cocina360/features/organization/data/services/dto/organization_dto.dart';
import 'package:cocina360/features/organization/data/services/dto/organization_member_dto.dart';
import 'package:cocina360/features/organization/data/services/dto/update_member_permissions_request.dart';
import 'package:cocina360/features/organization/data/services/dto/update_organization_request.dart';
import 'package:cocina360/shared/data/types/json.dart';
import 'package:cocina360/shared/infrastructure/remote/api_gateway_client.dart';

/// Reads organization data from the backend through the api-gw.
class OrganizationRemoteService {
  final ApiGatewayClient client;

  OrganizationRemoteService(this.client);

  /// `GET /organizations/{organizationId}` — the organization's details.
  Future<OrganizationDto> getOrganization(String organizationId) async {
    final data = await client.getJson('/organizations/$organizationId');
    return OrganizationDto.fromJson(data as JSON);
  }

  /// `GET /organizations` — organizations the current user belongs to. The
  /// backend resolves the requester from the JWT; no query params are needed.
  Future<List<OrganizationDto>> getMyOrganizations() async {
    final data = await client.getJson('/organizations');
    final list = (data as List).cast<JSON>();
    return list.map(OrganizationDto.fromJson).toList();
  }

  /// `POST /organizations` — creates a new organization owned by the current
  /// user (identity from the JWT) and returns it.
  Future<OrganizationDto> createOrganization(
    CreateOrganizationRequest request,
  ) async {
    final data = await client.postJson('/organizations', body: request.toJson());
    return OrganizationDto.fromJson(data as JSON);
  }

  /// `GET /organizations/{organizationId}/members` — members enriched with
  /// profile data and permission levels.
  Future<List<OrganizationMemberDto>> getMembers(String organizationId) async {
    final data = await client.getJson(
      '/organizations/$organizationId/members',
    );
    final list = (data as List).cast<JSON>();
    return list.map(OrganizationMemberDto.fromJson).toList();
  }

  /// `PATCH /organizations/{organizationId}` — updates the organization and
  /// returns the new state.
  Future<OrganizationDto> updateOrganization(
    String organizationId,
    UpdateOrganizationRequest request,
  ) async {
    final data = await client.patchJson(
      '/organizations/$organizationId',
      body: request.toJson(),
    );
    return OrganizationDto.fromJson(data as JSON);
  }

  /// `DELETE /organizations/{organizationId}` — deletes the organization.
  /// Backend requires the requester to be its owner.
  Future<void> deleteOrganization(String organizationId) async {
    await client.deleteJson('/organizations/$organizationId');
  }

  /// `DELETE /organizations/{organizationId}/members/{memberId}` — removes a
  /// member from the organization.
  Future<void> removeMember(String organizationId, String memberId) async {
    await client.deleteJson('/organizations/$organizationId/members/$memberId');
  }

  /// `PUT /organizations/{organizationId}/members/{memberId}/permissions` —
  /// updates a member's per-context roles and returns the new member state.
  Future<OrganizationMemberDto> updateMemberPermissions(
    String organizationId,
    String memberId,
    UpdateMemberPermissionsRequest request,
  ) async {
    final data = await client.putJson(
      '/organizations/$organizationId/members/$memberId/permissions',
      body: request.toJson(),
    );
    return OrganizationMemberDto.fromJson(data as JSON);
  }

  /// `POST /organizations/{organizationId}/invitations` — invites a member by
  /// email. Returns 200 with no body.
  Future<void> inviteMember(String organizationId, String email) async {
    await client.postJson(
      '/organizations/$organizationId/invitations',
      body: {'invitedEmail': email},
    );
  }

  /// `GET /organizations/{organizationId}/invitations` — the organization's
  /// invitations.
  Future<List<InvitationDto>> getInvitations(String organizationId) async {
    final data = await client.getJson(
      '/organizations/$organizationId/invitations',
    );
    final list = (data as List).cast<JSON>();
    return list.map(InvitationDto.fromJson).toList();
  }

  /// `GET /invitations` — invitations addressed to the current user. The
  /// backend resolves the invited email from the JWT identity.
  Future<List<InvitationDto>> getMyInvitations() async {
    final data = await client.getJson('/invitations');
    final list = (data as List).cast<JSON>();
    return list.map(InvitationDto.fromJson).toList();
  }

  /// `POST /invitations/{id}/accept` — accept an invitation (response ignored).
  Future<void> acceptInvitation(String invitationId) async {
    await client.postJson('/invitations/$invitationId/accept');
  }

  /// `POST /invitations/{id}/decline` — decline an invitation (response ignored).
  Future<void> declineInvitation(String invitationId) async {
    await client.postJson('/invitations/$invitationId/decline');
  }
}
