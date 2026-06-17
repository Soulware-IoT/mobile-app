import 'package:cocina360/shared/domain/model/profile.dart';

abstract class ProfileRepository {
  Future<Profile> getCurrentProfile(String userId);
}
