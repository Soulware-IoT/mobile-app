import 'package:cocina360/features/organization/domain/model/invitation.dart';
import 'package:cocina360/shared/data/types/json.dart';

/// Maps the backend `InvitationResponse` (served through the api-gw) into the
/// [Invitation] domain model.
///
/// Wire shape: `{id, email, organizationId, invitedBy: ProfileSummary, invitedAt,
/// respondedAt, status}`. `email` is the invited person's address; `invitedBy`
/// (`{id, fullName, preferredName, email, avatarUrl}`) is the admin who sent it.
class InvitationDto {
  final String id;
  final String organizationId;
  final String invitedEmail;
  final String? invitedByFullName;
  final String? invitedByEmail;
  final String? status;
  final String? invitedAt;
  final String? respondedAt;

  const InvitationDto({
    required this.id,
    required this.organizationId,
    required this.invitedEmail,
    this.invitedByFullName,
    this.invitedByEmail,
    this.status,
    this.invitedAt,
    this.respondedAt,
  });

  factory InvitationDto.fromJson(JSON json) {
    final invitedBy = json['invitedBy'] as JSON?;

    return InvitationDto(
      id: json['id'] as String,
      organizationId: (json['organizationId'] as String?) ?? '',
      invitedEmail: (json['email'] as String?) ?? '',
      invitedByFullName: invitedBy?['fullName'] as String?,
      invitedByEmail: invitedBy?['email'] as String?,
      status: json['status'] as String?,
      invitedAt: json['invitedAt'] as String?,
      respondedAt: json['respondedAt'] as String?,
    );
  }

  Invitation toDomain() {
    return Invitation(
      id: id,
      organizationId: organizationId,
      invitedEmail: invitedEmail,
      invitedByFullName: invitedByFullName,
      invitedByEmail: invitedByEmail,
      status: invitationStatusFromString(status),
      invitedAt: invitedAt == null ? null : DateTime.tryParse(invitedAt!),
      respondedAt: respondedAt == null ? null : DateTime.tryParse(respondedAt!),
    );
  }
}
