import 'package:cocina360/features/organization/domain/model/invitation.dart';
import 'package:cocina360/l10n/app_localizations.dart';

/// Localized label for an [InvitationStatus] pill. Lives in the presentation
/// layer so the domain enum stays free of UI/locale concerns.
extension InvitationStatusLabel on InvitationStatus {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    InvitationStatus.pending => l10n.invitationStatusPending,
    InvitationStatus.accepted => l10n.invitationStatusAccepted,
    InvitationStatus.declined => l10n.invitationStatusDeclined,
  };
}
