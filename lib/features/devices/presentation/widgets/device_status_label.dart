import 'package:cocina360/features/devices/domain/model/device_status.dart';
import 'package:cocina360/l10n/app_localizations.dart';

/// Localized label for a [DeviceStatus] pill. Lives in the presentation layer so
/// the domain enum stays free of UI/locale concerns.
extension DeviceStatusLabel on DeviceStatus {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    DeviceStatus.provisioned => l10n.deviceStatusProvisioned,
    DeviceStatus.active => l10n.deviceStatusActive,
    DeviceStatus.inactive => l10n.deviceStatusInactive,
  };
}
