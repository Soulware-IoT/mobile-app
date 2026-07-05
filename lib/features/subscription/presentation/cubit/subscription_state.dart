import 'package:cocina360/features/subscription/domain/model/subscription.dart';

sealed class SubscriptionState {
  const SubscriptionState();
}

final class SubscriptionInitial extends SubscriptionState {
  const SubscriptionInitial();
}

final class SubscriptionLoading extends SubscriptionState {
  const SubscriptionLoading();
}

final class SubscriptionLoaded extends SubscriptionState {
  final Subscription subscription;

  /// True while a plan change / downgrade / resume is in flight.
  final bool updating;

  /// Set when the last action failed; the page surfaces it as a snackbar and
  /// keeps showing the last known subscription.
  final Object? updateError;

  const SubscriptionLoaded(
    this.subscription, {
    this.updating = false,
    this.updateError,
  });
}

final class SubscriptionError extends SubscriptionState {
  final Object error;

  const SubscriptionError(this.error);
}
