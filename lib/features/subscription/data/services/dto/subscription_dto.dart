import 'package:cocina360/features/subscription/domain/model/subscription.dart';
import 'package:cocina360/features/subscription/domain/model/subscription_plan.dart';
import 'package:cocina360/shared/data/types/json.dart';

/// Maps the backend `SubscriptionResponse` (served through the api-gw) into
/// the [Subscription] domain model.
class SubscriptionDto {
  final String id;
  final String organizationId;
  final String ownedBy;
  final String? plan;
  final String? currentPeriodEnd;
  final String? pendingPlan;

  const SubscriptionDto({
    required this.id,
    required this.organizationId,
    required this.ownedBy,
    this.plan,
    this.currentPeriodEnd,
    this.pendingPlan,
  });

  factory SubscriptionDto.fromJson(JSON json) {
    return SubscriptionDto(
      id: json['id'] as String,
      organizationId: json['organizationId'] as String,
      ownedBy: json['ownedBy'] as String,
      plan: json['plan'] as String?,
      currentPeriodEnd: json['currentPeriodEnd'] as String?,
      pendingPlan: json['pendingPlan'] as String?,
    );
  }

  Subscription toDomain() {
    return Subscription(
      id: id,
      organizationId: organizationId,
      ownedBy: ownedBy,
      plan: subscriptionPlanFromString(plan),
      currentPeriodEnd: currentPeriodEnd == null
          ? null
          : DateTime.tryParse(currentPeriodEnd!),
      // subscriptionPlanFromString falls back to FREE, which is right for a
      // pending cancellation but wrong for "nothing pending" — gate on null.
      pendingPlan: pendingPlan == null
          ? null
          : subscriptionPlanFromString(pendingPlan),
    );
  }
}
