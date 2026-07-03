/// Mirrors the backend invitation status enum (PENDING / ACCEPTED / DECLINED).
enum InvitationStatus { pending, accepted, declined }

/// Parses a backend invitation status (case-insensitive) into [InvitationStatus].
/// Unknown values fall back to [InvitationStatus.pending].
InvitationStatus invitationStatusFromString(String? value) =>
    switch (value?.toLowerCase()) {
      'accepted' => InvitationStatus.accepted,
      'declined' => InvitationStatus.declined,
      _ => InvitationStatus.pending,
    };

class Invitation {
  final String id;
  final String organizationId;

  /// The invited person's email (backend `InvitationResponse.email`).
  final String invitedEmail;

  /// The admin who sent the invitation (backend `InvitationResponse.invitedBy`,
  /// a `ProfileSummary`). Null only if the backend omitted it.
  final String? invitedByFullName;
  final String? invitedByEmail;

  final InvitationStatus status;
  final DateTime? invitedAt;
  final DateTime? respondedAt;

  const Invitation({
    required this.id,
    required this.organizationId,
    required this.invitedEmail,
    this.invitedByFullName,
    this.invitedByEmail,
    required this.status,
    this.invitedAt,
    this.respondedAt,
  });
}
