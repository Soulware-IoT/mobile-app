sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final String userId;

  const Authenticated(this.userId);
}

final class OfflineAuthenticated extends AuthState {
  final String userId;

  const OfflineAuthenticated(this.userId);
}

final class NotAuthenticated extends AuthState {
  const NotAuthenticated();
}

final class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);
}