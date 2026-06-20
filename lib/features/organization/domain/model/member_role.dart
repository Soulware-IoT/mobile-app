/// Mirrors the backend `permission_level` enum
/// (`admin` / `lieutenant` / `assignee` / `none`).
enum MemberRole { admin, lieutenant, assignee, none }

extension MemberRoleX on MemberRole {
  /// Uppercase label used for the member badge in the mockup.
  String get label => switch (this) {
    MemberRole.admin => 'ADMIN',
    MemberRole.lieutenant => 'LIEUTENANT',
    MemberRole.assignee => 'ASSIGNEE',
    MemberRole.none => 'NONE',
  };

  /// Wire value expected by the backend (`PermissionLevel` enum is uppercase in
  /// the REST contract: ADMIN / LIEUTENANT / ASSIGNEE / NONE).
  String get apiValue => name.toUpperCase();

  /// Higher number = more privilege. Used to pick the badge role.
  int get rank => switch (this) {
    MemberRole.admin => 3,
    MemberRole.lieutenant => 2,
    MemberRole.assignee => 1,
    MemberRole.none => 0,
  };
}

/// Parses a backend permission level (case-insensitive) into [MemberRole].
MemberRole memberRoleFromString(String? value) =>
    switch (value?.toLowerCase()) {
      'admin' => MemberRole.admin,
      'lieutenant' => MemberRole.lieutenant,
      'assignee' => MemberRole.assignee,
      _ => MemberRole.none,
    };

/// The badge shows the highest privilege a member holds across the three
/// permission domains (security / iot / internal_control).
MemberRole highestRole(Iterable<MemberRole> roles) => roles.fold(
  MemberRole.none,
  (best, role) => role.rank > best.rank ? role : best,
);
