import 'package:cocina360/features/organization/data/services/organization_remote_service.dart';
import 'package:cocina360/features/organization/domain/repositories/organization_repository.dart';
import 'package:cocina360/shared/infrastructure/network/network_checker.dart';

class OrganizationRepositoryImpl implements OrganizationRepository {
  final OrganizationRemoteService remoteService;
  final NetworkChecker connectionChecker;

  OrganizationRepositoryImpl(this.remoteService, this.connectionChecker);

  @override
  Future<OrganizationWithMembers?> getPrimaryOrganization(String userId) async {
    final online = await connectionChecker.isConnected;
    if (!online) {
      throw Exception('Sin conexión a internet');
    }

    final organizations = await remoteService.getMyOrganizations(userId);
    if (organizations.isEmpty) return null;

    // The mockup shows a single organization; pick the first membership as the
    // user's primary org. A switcher can be added later if needed.
    final organization = organizations.first.toDomain();

    final memberDtos = await remoteService.getMembers(organization.id);
    final members = memberDtos.map((dto) => dto.toDomain()).toList();

    return OrganizationWithMembers(organization, members);
  }
}
