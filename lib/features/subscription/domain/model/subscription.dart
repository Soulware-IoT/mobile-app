import 'package:cocina360/features/subscription/domain/model/subscription_plan.dart';

/// An organization's billing state, as shown on the Subscription screen.
class Subscription {
  final String id;
  final String organizationId;
  final String ownedBy;
  final SubscriptionPlan plan;

  /// Null while on FREE (nothing billed, so no period to report).
  final DateTime? currentPeriodEnd;

  /// True when a downgrade to FREE is scheduled for [currentPeriodEnd].
  final bool cancelAtPeriodEnd;

  const Subscription({
    required this.id,
    required this.organizationId,
    required this.ownedBy,
    required this.plan,
    this.currentPeriodEnd,
    required this.cancelAtPeriodEnd,
  });

  /// Whether this organization already has billing on file (a paid plan not
  /// yet reverted to FREE), so a plan change doesn't need a new card.
  bool get hasBillingOnFile => plan.isPaid;
}
