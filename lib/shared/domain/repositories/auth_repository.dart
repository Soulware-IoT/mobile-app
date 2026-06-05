import 'package:tcompro/shared/presentation/session/auth/auth_state.dart';

abstract class AuthRepository {
  Stream<AuthState> get authStateChanges;

  Future<void> register({required String email, required String password});

  Future<void> googleRegister();

  Future<void> login({required String email, required String password});

  Future<void> googleLogin();

  Future<void> logout();
}
