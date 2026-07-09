import 'package:flutter/material.dart';
import 'package:cocina360/features/devices/domain/model/device_quota.dart';
import 'package:cocina360/features/devices/domain/model/edge_device.dart';
import 'package:cocina360/features/devices/presentation/widgets/device_status_label.dart';
import 'package:cocina360/l10n/app_localizations.dart';

/// Top summary of the Devices screen built from data that actually exists:
/// device count against the subscription quota (`used/limit`), active count,
/// and the edge gateway status.
class DevicesSummary extends StatelessWidget {
  final int total;
  final int active;
  final EdgeDevice? edge;
  final DeviceQuota? quota;

  /// Opens the edge device's detail screen. Only invoked when [edge] is
  /// non-null — the tile shows a plain "no gateway" label otherwise.
  final VoidCallback? onEdgeTap;

  const DevicesSummary({
    super.key,
    required this.total,
    required this.active,
    required this.edge,
    this.quota,
    this.onEdgeTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: l10n.devicesSummaryDevices,
            value: switch (quota) {
              null => '$total',
              DeviceQuota(isUnlimited: true) => '${quota!.used}/∞',
              _ => '${quota!.used}/${quota!.limit}',
            },
            icon: Icons.sensors,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: l10n.devicesSummaryActive,
            value: '$active',
            icon: Icons.check_circle_outline,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: l10n.devicesSummaryEdge,
            value: edge?.status.localizedLabel(l10n) ??
                l10n.devicesSummaryNoGateway,
            icon: Icons.router_outlined,
            onTap: edge == null ? null : onEdgeTap,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
