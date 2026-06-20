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
  final String invitedEmail;
  final InvitationStatus status;
  final DateTime? invitedAt;

  const Invitation({
    required this.id,
    required this.invitedEmail,
    required this.status,
    this.invitedAt,
  });
}
