import 'package:drift/drift.dart';
import 'package:cocina360/shared/data/services/base/local/local_service.dart';
import 'package:cocina360/shared/domain/model/profile.dart';
import 'package:cocina360/shared/infrastructure/local/dao/profile_dao.dart';
import 'package:cocina360/shared/infrastructure/local/database.dart';

/// On-device storage for the authenticated user's profile.
///
/// Backs offline profile rendering: once a profile has been fetched online it
/// is persisted here, so [Profile] stays available with no connectivity.
class ProfileLocalService extends BaseLocalService<ProfileDao> {
  ProfileLocalService(super.dao);

  Future<Profile?> getById(String id) async {
    final row = await dao.findById(id);
    if (row == null) return null;

    return Profile(
      id: row.id,
      fullName: row.fullName,
      email: row.email,
      avatarUrl: row.avatarUrl,
    );
  }

  Future<void> save(Profile profile) {
    return dao.upsert(
      ProfilesCompanion.insert(
        id: profile.id,
        fullName: profile.fullName,
        email: profile.email,
        avatarUrl: Value(profile.avatarUrl),
      ),
    );
  }

  Future<void> delete(String id) => dao.deleteById(id);
}
