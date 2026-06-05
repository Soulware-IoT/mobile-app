import 'package:tcompro/shared/data/services/auth_service.dart';
import 'package:tcompro/shared/domain/repositories/auth_repository.dart';
import 'package:tcompro/shared/presentation/session/auth/auth_state.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService service;

  AuthRepositoryImpl(this.service);

  @override
  Stream<AuthState> get authStateChanges =>
      service.supabase.auth.onAuthStateChange.map((data) {
        final session = data.session;

        if (session == null) {
          return const NotAuthenticated();
        }

        return Authenticated(session.user.id);
      });

  @override
  Future<void> register({required String email, required String password}) {
    return service.register(email: email, password: password);
  }

  @override
  Future<void> googleRegister() {
    return service.googleRegister();
  }

  @override
  Future<void> login({required String email, required String password}) {
    return service.regularLogin(email: email, password: password);
  }

  @override
  Future<void> googleLogin() {
    return service.googleLogin();
  }

  @override
  Future<void> logout() {
    return service.logout();
  }
}
