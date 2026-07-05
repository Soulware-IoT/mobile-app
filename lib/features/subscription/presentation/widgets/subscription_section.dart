import 'package:flutter/material.dart';
import 'package:cocina360/features/organization/domain/model/organization.dart';
import 'package:cocina360/features/subscription/domain/model/subscription.dart';
import 'package:cocina360/features/subscription/domain/model/subscription_plan.dart';
import 'package:cocina360/l10n/app_localizations.dart';

/// Plan, billing period and (owner-only) plan actions — embedded directly on
/// the Edit Organization screen rather than a separate page, so the whole
/// organization's state is visible and editable in one place.
class SubscriptionSection extends StatelessWidget {
  final Subscription subscription;
  final Organization organization;
  final bool updating;
  final bool isOwner;
  final VoidCallback onChangePlan;
  final VoidCallback onDowngrade;
  final VoidCallback onResume;

  const SubscriptionSection({
    super.key,
    required this.subscription,
    required this.organization,
    required this.updating,
    required this.isOwner,
    required this.onChangePlan,
    required this.onDowngrade,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AbsorbPointer(
      absorbing: updating,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PlanCard(subscription: subscription, owner: organization.owner),
          if (subscription.cancelAtPeriodEnd) ...[
            const SizedBox(height: 16),
            _CancelBanner(periodEnd: subscription.currentPeriodEnd),
          ],
          if (isOwner) ...[
            const SizedBox(height: 16),
            if (subscription.cancelAtPeriodEnd)
              FilledButton.icon(
                onPressed: onResume,
                icon: updating
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.autorenew, size: 18),
                label: Text(l10n.subscriptionResume),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              )
            else ...[
              FilledButton.icon(
                onPressed: onChangePlan,
                icon: updating
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upgrade, size: 18),
                label: Text(l10n.subscriptionChangePlanTitle),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
              if (subscription.plan.isPaid) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: onDowngrade,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: Text(l10n.subscriptionDowngrade),
                ),
              ],
            ],
          ],
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final Subscription subscription;
  final OrganizationOwner? owner;

  const _PlanCard({required this.subscription, this.owner});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final plan = subscription.plan;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.subscriptionCurrentPlanLabel,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _planLabel(l10n, plan),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              plan.isUnlimited
                  ? l10n.subscriptionUnlimitedDevices
                  : l10n.subscriptionDeviceLimit(plan.maxDevices),
              style: theme.textTheme.bodyMedium,
            ),
            if (subscription.currentPeriodEnd != null) ...[
              const SizedBox(height: 8),
              Text(
                l10n.subscriptionRenewsOn(_date(subscription.currentPeriodEnd!)),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (owner != null) ...[
              const SizedBox(height: 8),
              Text(
                l10n.subscriptionOwnedBy(owner!.fullName),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _planLabel(AppLocalizations l10n, SubscriptionPlan plan) => switch (plan) {
    SubscriptionPlan.free => l10n.subscriptionPlanFree,
    SubscriptionPlan.basic => l10n.subscriptionPlanBasic,
    SubscriptionPlan.professional => l10n.subscriptionPlanProfessional,
  };

  String _date(DateTime d) {
    final l = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${l.year}-${two(l.month)}-${two(l.day)}';
  }
}

class _CancelBanner extends StatelessWidget {
  final DateTime? periodEnd;

  const _CancelBanner({required this.periodEnd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final dateText = periodEnd == null ? '' : _date(periodEnd!);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_outlined, color: theme.colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.subscriptionCancelScheduled(dateText),
              style: TextStyle(color: theme.colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }

  String _date(DateTime d) {
    final l = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${l.year}-${two(l.month)}-${two(l.day)}';
  }
}
