import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cocina360/features/subscription/domain/model/subscription.dart';
import 'package:cocina360/features/subscription/domain/model/subscription_plan.dart';
import 'package:cocina360/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:cocina360/features/subscription/presentation/cubit/subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final SubscriptionRepository repository;

  SubscriptionCubit(this.repository) : super(const SubscriptionInitial());

  Future<void> load(String organizationId) async {
    emit(const SubscriptionLoading());
    try {
      final subscription = await repository.getSubscription(organizationId);
      emit(SubscriptionLoaded(subscription));
    } catch (e) {
      emit(SubscriptionError(e));
    }
  }

  Future<void> changePlan(
    String organizationId,
    SubscriptionPlan plan, {
    String? paymentMethodId,
  }) => _update(
    () => repository.changePlan(
      organizationId: organizationId,
      plan: plan,
      paymentMethodId: paymentMethodId,
    ),
  );

  Future<void> downgrade(String organizationId) =>
      _update(() => repository.downgrade(organizationId));

  Future<void> resume(String organizationId) =>
      _update(() => repository.resume(organizationId));

  Future<void> _update(Future<Subscription> Function() action) async {
    final current = state;
    if (current is! SubscriptionLoaded || current.updating) return;

    emit(SubscriptionLoaded(current.subscription, updating: true));
    try {
      final updated = await action();
      emit(SubscriptionLoaded(updated));
    } catch (e) {
      emit(SubscriptionLoaded(current.subscription, updateError: e));
    }
  }
}
