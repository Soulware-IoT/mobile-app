/// Lifecycle of a control format, mirroring the backend's transitions:
/// DRAFT → ACTIVE → (SUSPENDED ⇄ ACTIVE) → CEASED.
enum ControlFormatStatus { draft, active, suspended, ceased }

ControlFormatStatus controlFormatStatusFromString(String? value) {
  switch (value?.toUpperCase()) {
    case 'DRAFT':
      return ControlFormatStatus.draft;
    case 'ACTIVE':
      return ControlFormatStatus.active;
    case 'SUSPENDED':
      return ControlFormatStatus.suspended;
    case 'CEASED':
      return ControlFormatStatus.ceased;
    default:
      return ControlFormatStatus.draft;
  }
}

/// A lifecycle transition, one per backend endpoint
/// (`POST /formats/{id}/{action}`).
enum FormatAction { activate, suspend, resume, cease }

extension ControlFormatStatusRules on ControlFormatStatus {
  /// Only an ACTIVE format accepts new registries.
  bool get acceptsRegistries => this == ControlFormatStatus.active;

  /// Valid next actions, mirroring the backend's state machine so the UI only
  /// offers transitions the backend will accept.
  List<FormatAction> get availableActions => switch (this) {
        ControlFormatStatus.draft => const [FormatAction.activate],
        ControlFormatStatus.active => const [
            FormatAction.suspend,
            FormatAction.cease,
          ],
        ControlFormatStatus.suspended => const [
            FormatAction.resume,
            FormatAction.cease,
          ],
        ControlFormatStatus.ceased => const [],
      };
}
