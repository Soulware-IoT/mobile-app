import 'package:flutter/material.dart';
import 'package:cocina360/features/organization/domain/model/organization.dart';
import 'package:cocina360/l10n/app_localizations.dart';

/// Address + reference-point card.
///
/// GPS coordinates from the mockup are intentionally omitted: the backend
/// `organizations` table has no latitude/longitude columns, so this pass shows
/// only the address and the reference point ("Punto de referencia").
class OrganizationLocationCard extends StatelessWidget {
  final Organization organization;

  const OrganizationLocationCard({super.key, required this.organization});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final address = organization.addressLine;
    final reference = organization.addressReference;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Row(
              icon: Icons.location_on_outlined,
              label: l10n.addressHeader,
              value: address.isNotEmpty ? address : l10n.noAddressRegistered,
            ),
            if (reference != null && reference.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              Divider(color: theme.dividerColor.withValues(alpha: 0.4)),
              const SizedBox(height: 16),
              _Row(
                icon: Icons.navigation_outlined,
                label: l10n.referencePointHeader,
                value: reference,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Row({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
