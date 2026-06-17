import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cocina360/shared/data/services/auth_local_service.dart';
import 'package:cocina360/shared/data/services/auth_remote_service.dart';
import 'package:cocina360/shared/domain/model/auth_session.dart';
import 'package:cocina360/shared/domain/repositories/auth_repository.dart';
import 'package:cocina360/shared/infrastructure/network/network_checker.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteService remoteService;
  final AuthLocalService localService;
  final NetworkChecker connectionChecker;

  AuthRepositoryImpl(
    this.remoteService,
    this.localService,
    this.connectionChecker,
  );

  @override
  Stream<AuthSession> get authStateChanges =>
      remoteService.supabase.auth.onAuthStateChange.asyncMap((data) async {
        final session = data.session;

        if (session != null) {
          await localService.cacheUserId(session.user.id);
          return ActiveSession(session.user.id);
        }

        // Only an explicit sign-out clears the cached identity. A null session
        // from a failed token refresh (e.g. expired JWT while offline) must NOT
        // log the user out — we keep trusting the cached id until Supabase
        // actually reports a sign-out.
        if (data.event == AuthChangeEvent.signedOut) {
          await localService.clearCachedUserId();
          return const NoSession();
        }

        return _sessionFromCache();
      });

  @override
  Future<AuthSession> currentSession() async {
    final session = remoteService.supabase.auth.currentSession;
    if (session != null) {
      await localService.cacheUserId(session.user.id);
      return ActiveSession(session.user.id);
    }
    return _sessionFromCache();
  }

  /// Falls back to the cached identity when there is no live Supabase session.
  ///
  /// Offline with a cached id → offline-authenticated. Online with no session
  /// (and no explicit sign-out) → unauthenticated, so the user can re-login;
  /// the cache is intentionally left intact for a real `signedOut` event to
  /// clear, avoiding spurious logouts during token-refresh races.
  Future<AuthSession> _sessionFromCache() async {
    final cachedUserId = await localService.getCachedUserId();
    if (cachedUserId == null) return const NoSession();

    final online = await connectionChecker.isConnected;
    if (!online) return OfflineSession(cachedUserId);

    return const NoSession();
  }

  @override
  Future<void> register({required String email, required String password}) {
    return remoteService.register(email: email, password: password);
  }

  @override
  Future<void> googleRegister() {
    return remoteService.googleRegister();
  }

  @override
  Future<void> login({required String email, required String password}) {
    return remoteService.regularLogin(email: email, password: password);
  }

  @override
  Future<void> googleLogin() {
    return remoteService.googleLogin();
  }

  @override
  Future<void> logout() async {
    await localService.clearCachedUserId();
    return remoteService.logout();
  }
}
