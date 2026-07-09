import 'package:cocina360/features/subscription/domain/model/invoice.dart';
import 'package:cocina360/features/subscription/domain/model/subscription.dart';
import 'package:cocina360/features/subscription/domain/model/subscription_plan.dart';

abstract class SubscriptionRepository {
  /// Returns the organization's subscription (billing-enriched: live period
  /// end and pending plan change).
  Future<Subscription> getSubscription(String organizationId);

  /// Returns the organization's invoice history, most recent first. Owner
  /// only — the backend rejects other members.
  Future<List<Invoice>> listInvoices(String organizationId);

  /// Changes to a paid plan. [paymentMethodId] is required the first time an
  /// organization goes paid (no billing on file yet); omit it when switching
  /// between two paid plans. Upgrades apply immediately (prorated charge);
  /// paid→paid downgrades are deferred to the end of the current period.
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
