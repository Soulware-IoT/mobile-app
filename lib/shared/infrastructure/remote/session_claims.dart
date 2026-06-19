import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

/// One organization membership as embedded in the Supabase JWT by the
/// `custom_jwt_claims_hook` (claim `organizations[]`).
class OrganizationClaim {
  final String organizationId;
  final String memberId;

  const OrganizationClaim({
    required this.organizationId,
    required this.memberId,
  });
}

/// Reads the custom claims the Supabase access-token hook embeds in the JWT.
///
/// The backend exposes no "list my organizations" endpoint — a user's
/// memberships travel inside the access token (claim `organizations`), which is
/// also what the api-gw guards rely on. This decodes that claim locally.
class SessionClaims {
  final SupabaseClient supabase;

  const SessionClaims(this.supabase);

  /// Organizations the current user belongs to, newest session wins. Empty when
  /// there is no session or the token carries no memberships.
  List<OrganizationClaim> organizations() {
    final token = supabase.auth.currentSession?.accessToken;
    if (token == null) return const [];

    final orgs = _payload(token)['organizations'];
    if (orgs is! List) return const [];

    return orgs
        .whereType<Map>()
        .where((o) => o['organization_id'] != null && o['member_id'] != null)
        .map(
          (o) => OrganizationClaim(
            organizationId: o['organization_id'] as String,
            memberId: o['member_id'] as String,
          ),
        )
        .toList();
  }

  /// Decodes the JWT payload (middle segment) into a JSON map.
  Map<String, dynamic> _payload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return const {};

    try {
      final decoded = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final json = jsonDecode(decoded);
      return json is Map<String, dynamic> ? json : const {};
    } catch (_) {
      return const {};
    }
  }
}
