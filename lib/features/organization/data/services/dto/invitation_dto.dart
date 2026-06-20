import 'package:cocina360/features/organization/domain/model/invitation.dart';
import 'package:cocina360/shared/data/types/json.dart';

/// Maps the backend `InvitationResponse` (served through the api-gw) into the
/// [Invitation] domain model. Only the fields the screen needs are kept.
class InvitationDto {
  final String id;
  final String invitedEmail;
  final String? status;
  final String? invitedAt;

  const InvitationDto({
    required this.id,
    required this.invitedEmail,
    this.status,
    this.invitedAt,
  });

  factory InvitationDto.fromJson(JSON json) {
    return InvitationDto(
      id: json['id'] as String,
      invitedEmail: (json['invitedEmail'] as String?) ?? '',
      status: json['status'] as String?,
      invitedAt: json['invitedAt'] as String?,
    );
  }

  Invitation toDomain() {
    return Invitation(
      id: id,
      invitedEmail: invitedEmail,
      status: invitationStatusFromString(status),
      invitedAt: invitedAt == null ? null : DateTime.tryParse(invitedAt!),
    );
  }
}
