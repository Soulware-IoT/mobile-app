import 'package:tcompro/shared/data/services/profile_local_service.dart';
import 'package:tcompro/shared/data/services/profile_service.dart';
import 'package:tcompro/shared/domain/exception/profile_not_found_exception.dart';
import 'package:tcompro/shared/domain/model/profile.dart';
import 'package:tcompro/shared/domain/repositories/profile_repository.dart';
import 'package:tcompro/shared/infrastructure/network/network_checker.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileService remoteService;
  final ProfileLocalService localService;
  final NetworkChecker connectionChecker;

  ProfileRepositoryImpl(
    this.remoteService,
    this.localService,
    this.connectionChecker,
  );

  /// Local-first: serve the cached profile when offline or when the network
  /// call fails, and refresh + persist it whenever we can reach the server.
  @override
  Future<Profile> getCurrentProfile(String userId) async {
    final cached = await localService.getById(userId);
    final online = await connectionChecker.isConnected;

    if (online) {
      try {
        final dto = await remoteService.getProfileById(userId);
        if (dto != null) {
          final profile = dto.toDomain();
          await localService.save(profile);
          return profile;
        }
      } catch (_) {}
    }

    if (cached != null) return cached;
    throw ProfileNotFoundException(userId);
  }
}
