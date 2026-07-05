import 'package:cocina360/features/subscription/domain/model/subscription.dart';
import 'package:cocina360/features/subscription/domain/model/subscription_plan.dart';

abstract class SubscriptionRepository {
  /// Returns the organization's subscription (billing-enriched: live period
  /// end and pending-cancellation flag).
  Future<Subscription> getSubscription(String organizationId);

  /// Changes to a paid plan. [paymentMethodId] is required the first time an
  /// organization goes paid (no billing on file yet); omit it when switching
  /// between two paid plans.
  Future<Subscription> changePlan({
    required String organizationId,
    required SubscriptionPlan plan,
    String? paymentMethodId,
  });

  /// Schedules a downgrade to FREE at the end of the current paid period.
  Future<Subscription> downgrade(String organizationId);

  /// Cancels a pending downgrade — the subscription keeps renewing.
  Future<Subscription> resume(String organizationId);
}
