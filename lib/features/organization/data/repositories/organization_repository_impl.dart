import 'package:cocina360/features/organization/data/services/organization_remote_service.dart';
import 'package:cocina360/features/organization/domain/repositories/organization_repository.dart';
import 'package:cocina360/shared/infrastructure/network/network_checker.dart';
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
      throw Exception('Sin conexión a internet');
    }

    // The backend has no "list my organizations" endpoint — memberships come
    // from the JWT. The mockup shows a single org; pick the first membership as
    // the user's primary org. A switcher can be added later if needed.
    final memberships = sessionClaims.organizations();
    if (memberships.isEmpty) return null;

    final organizationId = memberships.first.organizationId;

    final organization =
        (await remoteService.getOrganization(organizationId)).toDomain();

    final memberDtos = await remoteService.getMembers(organizationId);
    final members = memberDtos.map((dto) => dto.toDomain()).toList();

    return OrganizationWithMembers(organization, members);
  }
}
