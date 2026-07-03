import 'package:flutter/material.dart';
import 'package:cocina360/features/processes/domain/model/control_format_status.dart';
import 'package:cocina360/l10n/app_localizations.dart';

/// Localized label for a [ControlFormatStatus] pill. Lives in the presentation
/// layer so the domain enum stays free of UI/locale concerns.
extension ControlFormatStatusLabel on ControlFormatStatus {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    ControlFormatStatus.draft => l10n.formatStatusDraft,
    ControlFormatStatus.active => l10n.formatStatusActive,
    ControlFormatStatus.suspended => l10n.formatStatusSuspended,
    ControlFormatStatus.ceased => l10n.formatStatusCeased,
  };
}

/// Localized label for a [FormatAction] menu entry.
extension FormatActionLabel on FormatAction {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    FormatAction.activate => l10n.formatActionActivate,
    FormatAction.suspend => l10n.formatActionSuspend,
    FormatAction.resume => l10n.formatActionResume,
    FormatAction.cease => l10n.formatActionCease,
  };
}

/// Color-coded pill for a [ControlFormatStatus]: ACTIVE green, DRAFT amber,
/// SUSPENDED grey, CEASED red.
class FormatStatusChip extends StatelessWidget {
  final ControlFormatStatus status;

  const FormatStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      ControlFormatStatus.active => (
        const Color(0xFFD7F2DD),
        const Color(0xFF1B7A3D),
      ),
      ControlFormatStatus.draft => (
        const Color(0xFFFCE8B2),
        const Color(0xFF7A5B00),
      ),
      ControlFormatStatus.suspended => (
        const Color(0xFFE6E8EB),
        const Color(0xFF5A6470),
      ),
      ControlFormatStatus.ceased => (
        const Color(0xFFF8D7DA),
        const Color(0xFF9A2530),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.localizedLabel(AppLocalizations.of(context)!),
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
