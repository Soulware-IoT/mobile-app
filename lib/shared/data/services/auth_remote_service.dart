import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cocina360/shared/data/services/base/remote/remote_service.dart';

class AuthRemoteService extends RemoteService {
  final String authCallbackUrl =
      "https://cocina360.soulware.site/auth-callback?platform=mobile";

  AuthRemoteService(super.supabase);

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
    return await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: authCallbackUrl,
    );
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}
