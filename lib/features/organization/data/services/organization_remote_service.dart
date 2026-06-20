import 'package:cocina360/features/organization/data/services/dto/organization_dto.dart';
import 'package:cocina360/features/organization/data/services/dto/organization_member_dto.dart';
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
}
