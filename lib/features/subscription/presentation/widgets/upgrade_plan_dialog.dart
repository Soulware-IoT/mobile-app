import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:cocina360/features/subscription/domain/model/subscription_plan.dart';
import 'package:cocina360/l10n/app_localizations.dart';

/// Result of a successful [showUpgradePlanDialog] call: the plan the user
/// picked and, when a card was required, the Stripe payment method id.
class UpgradePlanResult {
  final SubscriptionPlan plan;
  final String? paymentMethodId;

  const UpgradePlanResult(this.plan, this.paymentMethodId);
}

/// Lets the user pick a paid plan and, if the organization has no billing on
/// file yet, enter a card. Tokenizes the card via the Stripe SDK
/// (`createPaymentMethod`) — the raw card details never touch this app's own
/// backend, only the resulting payment method id does.
Future<UpgradePlanResult?> showUpgradePlanDialog(
  BuildContext context, {
  required SubscriptionPlan current,
  required bool requiresCard,
}) {
  return showDialog<UpgradePlanResult>(
    context: context,
    builder: (_) =>
        _UpgradePlanDialog(current: current, requiresCard: requiresCard),
  );
}

class _UpgradePlanDialog extends StatefulWidget {
  final SubscriptionPlan current;
  final bool requiresCard;

  const _UpgradePlanDialog({required this.current, required this.requiresCard});

  @override
  State<_UpgradePlanDialog> createState() => _UpgradePlanDialogState();
}

class _UpgradePlanDialogState extends State<_UpgradePlanDialog> {
  late SubscriptionPlan _selected;
  CardFieldInputDetails? _card;
  bool _submitting = false;
  String? _error;

  static const _paidPlans = [SubscriptionPlan.basic, SubscriptionPlan.professional];

  @override
  void initState() {
    super.initState();
    _selected = _paidPlans.firstWhere(
      (p) => p != widget.current,
      orElse: () => SubscriptionPlan.basic,
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (widget.requiresCard && (_card == null || !_card!.complete)) {
      setState(() => _error = l10n.subscriptionCardIncomplete);
      return;
    }
    if (Stripe.publishableKey.isEmpty) {
      setState(() => _error = l10n.subscriptionStripeNotConfigured);
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      String? paymentMethodId;
      if (widget.requiresCard) {
        final paymentMethod = await Stripe.instance.createPaymentMethod(
          params: const PaymentMethodParams.card(
            paymentMethodData: PaymentMethodData(),
          ),
        );
        paymentMethodId = paymentMethod.id;
      }
      if (mounted) {
        Navigator.of(
          context,
        ).pop(UpgradePlanResult(_selected, paymentMethodId));
      }
    } on StripeException catch (e) {
      setState(() {
        _submitting = false;
        _error = e.error.localizedMessage ?? e.error.message;
      });
    } catch (e) {
      setState(() {
        _submitting = false;
        _error = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.subscriptionChangePlanTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RadioGroup<SubscriptionPlan>(
              groupValue: _selected,
              onChanged: (v) {
                if (_submitting || v == null) return;
                setState(() => _selected = v);
              },
              child: Column(
                children: [
                  for (final plan in _paidPlans)
                    RadioListTile<SubscriptionPlan>(
                      contentPadding: EdgeInsets.zero,
                      value: plan,
                      title: Text(_planLabel(l10n, plan)),
                    ),
                ],
              ),
            ),
            if (widget.requiresCard) ...[
              const SizedBox(height: 12),
              Text(l10n.subscriptionCardLabel),
              const SizedBox(height: 8),
              CardField(
                enablePostalCode: true,
                onCardChanged: (details) => setState(() => _card = details),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting
              ? null
              : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.confirm),
        ),
      ],
    );
  }

  String _planLabel(AppLocalizations l10n, SubscriptionPlan plan) => switch (plan) {
    SubscriptionPlan.free => l10n.subscriptionPlanFree,
    SubscriptionPlan.basic => l10n.subscriptionPlanBasic,
    SubscriptionPlan.professional => l10n.subscriptionPlanProfessional,
  };
}
