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
  final bool cancelAtPeriodEnd;

  const SubscriptionDto({
    required this.id,
    required this.organizationId,
    required this.ownedBy,
    this.plan,
    this.currentPeriodEnd,
    this.cancelAtPeriodEnd = false,
  });

  factory SubscriptionDto.fromJson(JSON json) {
    return SubscriptionDto(
      id: json['id'] as String,
      organizationId: json['organizationId'] as String,
      ownedBy: json['ownedBy'] as String,
      plan: json['plan'] as String?,
      currentPeriodEnd: json['currentPeriodEnd'] as String?,
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] as bool? ?? false,
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
      cancelAtPeriodEnd: cancelAtPeriodEnd,
    );
  }
}
