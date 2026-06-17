import 'package:cocina360/shared/domain/model/auth_session.dart';

abstract class AuthRepository {
  Stream<AuthSession> get authStateChanges;

  /// Resolves the session at startup so the UI never gets stuck waiting on the
  /// auth stream — critical when the app cold-starts with no connectivity.
  Future<AuthSession> currentSession();

  Future<void> register({required String email, required String password});

  Future<void> googleRegister();

  Future<void> login({required String email, required String password});

  Future<void> googleLogin();

  Future<void> logout();
}
