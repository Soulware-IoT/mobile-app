import 'package:cocina360/features/subscription/data/services/subscription_remote_service.dart';
import 'package:cocina360/features/subscription/domain/model/subscription.dart';
import 'package:cocina360/features/subscription/domain/model/subscription_plan.dart';
import 'package:cocina360/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:cocina360/shared/infrastructure/network/network_checker.dart';
import 'package:cocina360/shared/infrastructure/network/no_connection_exception.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteService remoteService;
  final NetworkChecker connectionChecker;

  SubscriptionRepositoryImpl(this.remoteService, this.connectionChecker);

  @override
  Future<Subscription> getSubscription(String organizationId) async {
    await _requireConnection();
    final dto = await remoteService.getSubscription(organizationId);
    return dto.toDomain();
  }

  @override
  Future<Subscription> changePlan({
    required String organizationId,
    required SubscriptionPlan plan,
    String? paymentMethodId,
  }) async {
    await _requireConnection();
    final dto = await remoteService.changePlan(
      organizationId,
      plan,
      paymentMethodId: paymentMethodId,
    );
    return dto.toDomain();
  }

  @override
  Future<Subscription> downgrade(String organizationId) async {
    await _requireConnection();
    final dto = await remoteService.downgrade(organizationId);
    return dto.toDomain();
  }

  @override
  Future<Subscription> resume(String organizationId) async {
    await _requireConnection();
    final dto = await remoteService.resume(organizationId);
    return dto.toDomain();
  }

  Future<void> _requireConnection() async {
    final online = await connectionChecker.isConnected;
    if (!online) {
      throw const NoConnectionException();
    }
  }
}
