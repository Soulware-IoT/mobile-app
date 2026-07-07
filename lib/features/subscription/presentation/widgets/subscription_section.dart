import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cocina360/features/organization/domain/model/organization.dart';
import 'package:cocina360/features/subscription/domain/model/invoice.dart';
import 'package:cocina360/features/subscription/domain/model/subscription.dart';
import 'package:cocina360/features/subscription/domain/model/subscription_plan.dart';
import 'package:cocina360/features/subscription/presentation/cubit/invoices_cubit.dart';
import 'package:cocina360/features/subscription/presentation/cubit/invoices_state.dart';
import 'package:cocina360/l10n/app_localizations.dart';
import 'package:cocina360/shared/presentation/error/localized_error.dart';

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
          if (subscription.hasPendingDowngrade) ...[
            const SizedBox(height: 16),
            _PendingChangeBanner(
              pendingPlan: subscription.pendingPlan!,
              periodEnd: subscription.currentPeriodEnd,
            ),
          ],
          if (isOwner) ...[
            const SizedBox(height: 16),
            if (subscription.hasPendingDowngrade)
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
            // Invoices expose billed amounts, so the backend only serves them
            // to the owner — don't render (or request) the section for others.
            const SizedBox(height: 24),
            _InvoicesSection(),
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

    // width: infinity so the card spans the full section width rather than
    // shrink-wrapping the plan text.
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.colorScheme.surfaceContainerLow,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
              planLabel(l10n, plan),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            if (plan.isPaid) ...[
              const SizedBox(height: 2),
              Text(
                l10n.subscriptionPlanMonthlyPrice(plan.displayPriceUsd),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
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
}

class _PendingChangeBanner extends StatelessWidget {
  final SubscriptionPlan pendingPlan;
  final DateTime? periodEnd;

  const _PendingChangeBanner({required this.pendingPlan, this.periodEnd});

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
              l10n.subscriptionPendingPlanScheduled(
                planLabel(l10n, pendingPlan),
                dateText,
              ),
              style: TextStyle(color: theme.colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoicesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.invoicesTitle,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<InvoicesCubit, InvoicesState>(
          builder: (context, state) => switch (state) {
            InvoicesInitial() || InvoicesLoading() => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(),
              ),
            ),
            InvoicesError(:final error) => Text(
              localizedError(context, error),
              style: TextStyle(color: theme.colorScheme.error),
            ),
            InvoicesLoaded(:final invoices) when invoices.isEmpty => Text(
              l10n.invoicesEmpty,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            InvoicesLoaded(:final invoices) => Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: theme.colorScheme.surfaceContainerLow,
              child: Column(
                children: [
                  for (final (index, invoice) in invoices.indexed) ...[
                    if (index > 0)
                      Divider(
                        height: 1,
                        color: theme.dividerColor.withValues(alpha: 0.4),
                      ),
                    _InvoiceTile(invoice: invoice),
                  ],
                ],
              ),
            ),
          },
        ),
      ],
    );
  }
}

class _InvoiceTile extends StatelessWidget {
  final Invoice invoice;

  const _InvoiceTile({required this.invoice});

  Future<void> _open(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final url = invoice.hostedInvoiceUrl ?? invoice.invoicePdfUrl;
    if (url == null) return;

    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.invoiceOpenError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasLink =
        invoice.hostedInvoiceUrl != null || invoice.invoicePdfUrl != null;
    final amount = NumberFormat.simpleCurrency(
      name: invoice.currency.toUpperCase(),
    ).format(invoice.amountPaid / 100);

    return ListTile(
      onTap: hasLink ? () => _open(context) : null,
      leading: Icon(
        Icons.receipt_long_outlined,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        invoice.number ??
            (invoice.createdAt == null ? '—' : _date(invoice.createdAt!)),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: invoice.createdAt == null
          ? null
          : Text(_date(invoice.createdAt!)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(amount, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          _InvoiceStatusChip(status: invoice.status),
        ],
      ),
    );
  }
}

/// Color-coded pill for a Stripe invoice status, reusing the palette of
/// `FormatStatusChip`/`DeviceStatusBadge`.
class _InvoiceStatusChip extends StatelessWidget {
  final String status;

  const _InvoiceStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (bg, fg, label) = switch (status) {
      'paid' => (
        const Color(0xFFD7F2DD),
        const Color(0xFF1B7A3D),
        l10n.invoiceStatusPaid,
      ),
      'open' => (
        const Color(0xFFFCE8B2),
        const Color(0xFF7A5B00),
        l10n.invoiceStatusOpen,
      ),
      'draft' => (
        const Color(0xFFE6E8EB),
        const Color(0xFF5A6470),
        l10n.invoiceStatusDraft,
      ),
      'void' => (
        const Color(0xFFF8D7DA),
        const Color(0xFF9A2530),
        l10n.invoiceStatusVoid,
      ),
      'uncollectible' => (
        const Color(0xFFF8D7DA),
        const Color(0xFF9A2530),
        l10n.invoiceStatusUncollectible,
      ),
      _ => (const Color(0xFFE6E8EB), const Color(0xFF5A6470), status),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
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

/// Localized display name for a plan, shared by the plan card, the pending
/// banner and the plan picker.
String planLabel(AppLocalizations l10n, SubscriptionPlan plan) =>
    switch (plan) {
      SubscriptionPlan.free => l10n.subscriptionPlanFree,
      SubscriptionPlan.basic => l10n.subscriptionPlanBasic,
      SubscriptionPlan.professional => l10n.subscriptionPlanProfessional,
    };

String _date(DateTime d) {
  final l = d.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${l.year}-${two(l.month)}-${two(l.day)}';
}
