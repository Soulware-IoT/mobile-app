import 'package:tcompro/shared/data/services/base/remote/remote_service.dart';
import 'package:tcompro/shared/data/services/dto/profile_dto.dart';

class ProfileService extends RemoteService {
  ProfileService(super.supabase);

  Future<ProfileDto?> getProfileById(String id) async {
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;

    return ProfileDto.fromJson(response);
  }
}