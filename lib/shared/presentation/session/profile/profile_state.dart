import 'package:cocina360/shared/domain/model/profile.dart';

sealed class ProfileState {
  const ProfileState();
}

final class NoProfile extends ProfileState {
  const NoProfile();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  final Profile profile;

  const ProfileLoaded(this.profile);
}

final class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);
}
