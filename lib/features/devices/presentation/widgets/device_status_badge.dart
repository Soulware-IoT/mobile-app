import 'package:flutter/material.dart';
import 'package:cocina360/features/devices/domain/model/device_status.dart';
import 'package:cocina360/features/devices/presentation/widgets/device_status_label.dart';
import 'package:cocina360/l10n/app_localizations.dart';

/// Color-coded pill for a [DeviceStatus]: ACTIVE green, PROVISIONED amber,
/// INACTIVE grey.
class DeviceStatusBadge extends StatelessWidget {
  final DeviceStatus status;

  const DeviceStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      DeviceStatus.active => (const Color(0xFFD7F2DD), const Color(0xFF1B7A3D)),
      DeviceStatus.provisioned => (
        const Color(0xFFFCE8B2),
        const Color(0xFF7A5B00),
      ),
      DeviceStatus.inactive => (
        const Color(0xFFE6E8EB),
        const Color(0xFF5A6470),
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
