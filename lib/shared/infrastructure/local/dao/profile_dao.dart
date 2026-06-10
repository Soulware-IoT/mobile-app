import 'package:drift/drift.dart';
import 'package:tcompro/shared/infrastructure/local/database.dart';
import 'package:tcompro/shared/infrastructure/local/tables/profiles_table.dart';

part 'profile_dao.g.dart';

@DriftAccessor(tables: [Profiles])
class ProfileDao extends DatabaseAccessor<AppDatabase> with _$ProfileDaoMixin {
  ProfileDao(super.db);

  Future<ProfileRow?> findById(String id) {
    return (select(profiles)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsert(ProfilesCompanion profile) {
    return into(profiles).insertOnConflictUpdate(profile);
  }

  Future<void> deleteById(String id) {
    return (delete(profiles)..where((t) => t.id.equals(id))).go();
  }
}
