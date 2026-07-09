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

  /// Mirrors the backend's tier ranking: switching to a higher plan is an
  /// upgrade (applies immediately, prorated charge); switching to a lower one
  /// is a downgrade (deferred to the end of the current period).
  bool isHigherThan(SubscriptionPlan other) => index > other.index;

  /// Monthly price in USD, for display only (not sent to the backend, which
  /// resolves the actual amount from the plan name on its side).
  double? get monthlyPriceUsd => switch (this) {
    SubscriptionPlan.free => null,
    SubscriptionPlan.basic => 5.00,
    SubscriptionPlan.professional => 15.00,
  };

  /// Formatted as `$5.00`, for display only.
  String get displayPriceUsd => '\$${monthlyPriceUsd!.toStringAsFixed(2)}';
}

SubscriptionPlan subscriptionPlanFromString(String? value) =>
    switch (value?.toUpperCase()) {
      'BASIC' => SubscriptionPlan.basic,
      'PROFESSIONAL' => SubscriptionPlan.professional,
      _ => SubscriptionPlan.free,
    };
