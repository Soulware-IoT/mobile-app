import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tcompro/shared/data/services/base/remote/remote_service.dart';

class AuthService extends RemoteService {
  final String authCallbackUrl = "com.soulware.tcompro://auth-callback";

  AuthService(super.supabase);

  Future<AuthResponse> register({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: authCallbackUrl,
    );
  }

  Future<bool> googleRegister() async {
    return await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: authCallbackUrl,
    );
  }

  Future<AuthResponse> regularLogin({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<bool> googleLogin() async {
    return await supabase.auth.signInWithOAuth(OAuthProvider.google);
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}
