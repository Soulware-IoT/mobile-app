import 'package:cocina360/features/subscription/domain/model/subscription_plan.dart';

/// An organization's billing state, as shown on the Subscription screen.
class Subscription {
  final String id;
  final String organizationId;
  final String ownedBy;
  final SubscriptionPlan plan;

  /// Null while on FREE (nothing billed, so no period to report).
  final DateTime? currentPeriodEnd;

  /// The plan a scheduled downgrade will move to at [currentPeriodEnd] —
  /// FREE for a pending cancellation, a cheaper paid plan for a paid→paid
  /// downgrade. Null when no change is scheduled.
  final SubscriptionPlan? pendingPlan;

  const Subscription({
    required this.id,
    required this.organizationId,
    required this.ownedBy,
    required this.plan,
    this.currentPeriodEnd,
    this.pendingPlan,
  });

  /// True when a downgrade (to FREE or a cheaper paid plan) is scheduled for
  /// the end of the current period.
  bool get hasPendingDowngrade => pendingPlan != null;

  /// Whether this organization already has billing on file (a paid plan not
  /// yet reverted to FREE), so a plan change doesn't need a new card.
  bool get hasBillingOnFile => plan.isPaid;
}
