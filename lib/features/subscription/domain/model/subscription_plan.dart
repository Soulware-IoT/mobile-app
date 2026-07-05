/// Mirrors the backend `SubscriptionPlan` enum. Device limits are duplicated
/// here (not fetched) since they're fixed per plan and the backend doesn't
/// expose them on the subscription response.
enum SubscriptionPlan { free, basic, professional }

extension SubscriptionPlanX on SubscriptionPlan {
  /// Wire value expected by the backend (uppercase in the REST contract).
  String get apiValue => name.toUpperCase();

  /// -1 for professional means unlimited; check [isUnlimited] instead of
  /// comparing directly.
  int get maxDevices => switch (this) {
    SubscriptionPlan.free => 3,
    SubscriptionPlan.basic => 10,
    SubscriptionPlan.professional => -1,
  };

  bool get isUnlimited => this == SubscriptionPlan.professional;

  bool get isPaid => this != SubscriptionPlan.free;
}

SubscriptionPlan subscriptionPlanFromString(String? value) =>
    switch (value?.toUpperCase()) {
      'BASIC' => SubscriptionPlan.basic,
      'PROFESSIONAL' => SubscriptionPlan.professional,
      _ => SubscriptionPlan.free,
    };
