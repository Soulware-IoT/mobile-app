import 'package:tcompro/shared/domain/model/profile.dart';

abstract class ProfileRepository {
  Future<Profile> getCurrentProfile(String userId);
}
