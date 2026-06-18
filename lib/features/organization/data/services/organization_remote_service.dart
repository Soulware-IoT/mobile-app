import 'package:cocina360/features/organization/data/services/dto/organization_dto.dart';
import 'package:cocina360/features/organization/data/services/dto/organization_member_dto.dart';
import 'package:cocina360/shared/data/types/json.dart';
import 'package:cocina360/shared/infrastructure/remote/api_gateway_client.dart';

/// Reads organization data from the backend through the api-gw.
class OrganizationRemoteService {
  final ApiGatewayClient client;

  OrganizationRemoteService(this.client);

  /// `GET /api/v1/organizations?memberId={profileId}` — organizations the user
  /// belongs to (or owns).
  Future<List<OrganizationDto>> getMyOrganizations(String profileId) async {
    final data = await client.getJson(
      '/api/v1/organizations',
      query: {'memberId': profileId},
    );
    final list = (data as List).cast<JSON>();
    return list.map(OrganizationDto.fromJson).toList();
  }

  /// `GET /api/v1/organizations/{organizationId}/members` — members enriched
  /// with profile data and permission levels.
  Future<List<OrganizationMemberDto>> getMembers(String organizationId) async {
    final data = await client.getJson(
      '/api/v1/organizations/$organizationId/members',
    );
    final list = (data as List).cast<JSON>();
    return list.map(OrganizationMemberDto.fromJson).toList();
  }
}
