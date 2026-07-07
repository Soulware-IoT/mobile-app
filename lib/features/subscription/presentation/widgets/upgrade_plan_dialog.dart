import 'package:flutter/material.dart';
import 'package:cocina360/features/subscription/domain/model/subscription_plan.dart';
import 'package:cocina360/features/subscription/presentation/widgets/subscription_section.dart'
    show planLabel;
import 'package:cocina360/l10n/app_localizations.dart';

/// Lets the user pick a paid plan. Card capture (when the organization has no
/// billing on file yet) happens separately in the payment bottom sheet — see
/// `payment_sheet.dart`.
///
/// The current plan is shown disabled (the backend rejects a no-op change),
/// and each option states when it takes effect: upgrades apply immediately
/// with a prorated charge, paid→paid downgrades at the end of the period.
Future<SubscriptionPlan?> showUpgradePlanDialog(
  BuildContext context, {
  required SubscriptionPlan current,
}) {
  return showDialog<SubscriptionPlan>(
    context: context,
    builder: (_) => _UpgradePlanDialog(current: current),
  );
}

class _UpgradePlanDialog extends StatefulWidget {
  final SubscriptionPlan current;

  const _UpgradePlanDialog({required this.current});

  @override
  State<_UpgradePlanDialog> createState() => _UpgradePlanDialogState();
}

class _UpgradePlanDialogState extends State<_UpgradePlanDialog> {
  late SubscriptionPlan _selected;

  static const _paidPlans = [SubscriptionPlan.basic, SubscriptionPlan.professional];

  @override
  void initState() {
    super.initState();
    _selected = _paidPlans.firstWhere(
      (p) => p != widget.current,
      orElse: () => SubscriptionPlan.basic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.subscriptionChangePlanTitle),
      content: SingleChildScrollView(
        child: RadioGroup<SubscriptionPlan>(
          groupValue: _selected,
          onChanged: (v) {
            if (v == null || v == widget.current) return;
            setState(() => _selected = v);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final plan in _paidPlans)
                RadioListTile<SubscriptionPlan>(
                  contentPadding: EdgeInsets.zero,
                  value: plan,
                  enabled: plan != widget.current,
                  title: Text(planLabel(l10n, plan)),
                  subtitle: Text(
                    plan == widget.current
                        ? l10n.subscriptionCurrentPlanTag
                        : '${l10n.subscriptionPlanMonthlyPrice(plan.displayPriceUsd)}\n'
                              '${_timingNote(l10n, plan)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _selected == widget.current
              ? null
              : () => Navigator.of(context).pop(_selected),
          child: Text(l10n.confirm),
        ),
      ],
    );
  }

  /// Upgrades bill the prorated difference right away; paid→paid downgrades
  /// are deferred by the backend to the end of the current period.
  String _timingNote(AppLocalizations l10n, SubscriptionPlan plan) =>
      plan.isHigherThan(widget.current) || !widget.current.isPaid
      ? l10n.subscriptionUpgradeImmediate
      : l10n.subscriptionDowngradeAtPeriodEnd;
}
