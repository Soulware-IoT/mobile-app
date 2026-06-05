import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcompro/shared/domain/repositories/profile_repository.dart';
import 'package:tcompro/shared/presentation/session/profile/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository repository;

  ProfileCubit(this.repository) : super(const NoProfile());

  Future<void> loadProfile(String userId) async {
    emit(const ProfileLoading());

    try {
      final profile = await repository.getCurrentProfile(userId);
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  void clear() {
    emit(const NoProfile());
  }
}
