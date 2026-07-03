import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cocina360/shared/data/services/base/remote/remote_service.dart';

class AuthRemoteService extends RemoteService {
  /// Email-link confirmation must resolve cross-device (the link may be
  /// opened on a different device than the one that registered), so it goes
  /// through the web app's `/auth-callback`, which itself deep-links back
  /// into this app on Android once the session is resolved.
  ///
  /// Must match a Supabase "Redirect URLs" entry verbatim (no wildcard on
  /// this one) — keep in sync with the Auth dashboard.
  final String emailCallbackUrl =
      "https://app.cocina360.soulware.site/auth-callback";

  /// Google OAuth is a PKCE flow that always completes on this same device —
  /// its `code_verifier` lives in this app's own Supabase client storage, so
  /// the redirect must land back in the app directly via its registered deep
  /// link (matches the `site.soulware.cocina360://auth-callback` intent
  /// filter in AndroidManifest.xml), not through the web app. Redirecting to
  /// a web URL strands the code in a browser that can't complete the
  /// exchange, leaving the app stuck on its loading state indefinitely.
  final String googleRedirectUrl = "site.soulware.cocina360://auth-callback";

  AuthRemoteService(super.supabase);

  Future<AuthResponse> register({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: emailCallbackUrl,
    );
  }

  Future<bool> googleRegister() async {
    return await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: googleRedirectUrl,
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
      redirectTo: googleRedirectUrl,
    );
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}
