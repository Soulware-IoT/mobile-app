import 'package:tcompro/shared/data/services/profile_service.dart';
import 'package:tcompro/shared/domain/exception/profile_not_found_exception.dart';
import 'package:tcompro/shared/domain/model/profile.dart';
import 'package:tcompro/shared/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileService service;

  ProfileRepositoryImpl(this.service);

  @override
  Future<Profile> getCurrentProfile(String userId) async {
    final dto = await service.getProfileById(userId);

    if (dto == null) {
      throw ProfileNotFoundException(userId);
    }

    return dto.toDomain();
  }
}
