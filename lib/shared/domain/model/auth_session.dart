sealed class AuthSession {
  const AuthSession();
}

final class ActiveSession extends AuthSession {
  final String userId;
  const ActiveSession(this.userId);
}

final class OfflineSession extends AuthSession {
  final String userId;
  const OfflineSession(this.userId);
}

final class NoSession extends AuthSession {
  const NoSession();
}
