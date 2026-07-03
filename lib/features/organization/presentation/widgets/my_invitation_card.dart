import 'package:flutter/material.dart';
import 'package:cocina360/features/organization/domain/model/invitation.dart';
import 'package:cocina360/features/organization/presentation/widgets/invitation_status_label.dart';
import 'package:cocina360/l10n/app_localizations.dart';
import 'package:cocina360/shared/presentation/theme/theme.dart';

/// A card for one of the current user's invitations. Pending ones expose
/// Accept / Decline actions; resolved ones just show their status.
class MyInvitationCard extends StatelessWidget {
  final Invitation invitation;
  final bool processing;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const MyInvitationCard({
    super.key,
    required this.invitation,
    required this.processing,
    this.onAccept,
    this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPending = invitation.status == InvitationStatus.pending;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.mail_outline,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.invitationToOrganization,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                _StatusBadge(status: invitation.status),
              ],
            ),
            if (invitation.invitedByFullName != null ||
                invitation.invitedByEmail != null) ...[
              const SizedBox(height: 10),
              Text(
                AppLocalizations.of(context)!.invitedByLabel(
                  invitation.invitedByFullName ?? invitation.invitedByEmail!,
                ),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (invitation.invitedByFullName != null &&
                  invitation.invitedByEmail != null)
                Text(
                  invitation.invitedByEmail!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
            if (invitation.invitedAt != null) ...[
              const SizedBox(height: 6),
              Text(
                _formatDate(invitation.invitedAt!),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: processing ? null : onDecline,
                      child: Text(AppLocalizations.of(context)!.decline),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: processing ? null : onAccept,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.seedColor,
                        foregroundColor: Colors.white,
                      ),
                      child: processing
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(AppLocalizations.of(context)!.accept),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final local = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final InvitationStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final ({Color bg, Color fg}) colors = switch (status) {
      InvitationStatus.pending => (bg: const Color(0xFFFCE8B2), fg: const Color(0xFF7A5B00)),
      InvitationStatus.accepted => (bg: const Color(0xFFD7F0DC), fg: const Color(0xFF1B5E20)),
      InvitationStatus.declined => (bg: const Color(0xFFF5D7DC), fg: const Color(0xFF8A1C2B)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.localizedLabel(AppLocalizations.of(context)!),
        style: TextStyle(
          color: colors.fg,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
