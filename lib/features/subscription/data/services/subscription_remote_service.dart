import 'package:cocina360/features/subscription/data/services/dto/invoice_dto.dart';
import 'package:cocina360/features/subscription/data/services/dto/subscription_dto.dart';
import 'package:cocina360/features/subscription/domain/model/subscription_plan.dart';
import 'package:cocina360/shared/data/types/json.dart';
import 'package:cocina360/shared/infrastructure/remote/api_gateway_client.dart';

/// Talks to the backend's Subscriptions context through the api-gw.
class SubscriptionRemoteService {
  final ApiGatewayClient client;

  SubscriptionRemoteService(this.client);

  /// `GET /organizations/{organizationId}/subscription`
  Future<SubscriptionDto> getSubscription(String organizationId) async {
    final data = await client.getJson(
      '/organizations/$organizationId/subscription',
    );
    return SubscriptionDto.fromJson(data as JSON);
  }

  /// `GET /organizations/{organizationId}/subscription/invoices` (owner only)
  Future<List<InvoiceDto>> listInvoices(String organizationId) async {
    final data = await client.getJson(
      '/organizations/$organizationId/subscription/invoices',
    );
    return (data as List<dynamic>)
        .map((item) => InvoiceDto.fromJson(item as JSON))
        .toList();
  }

  /// `POST /organizations/{organizationId}/subscription/plan`
  Future<SubscriptionDto> changePlan(
    String organizationId,
    SubscriptionPlan plan, {
    String? paymentMethodId,
  }) async {
    final data = await client.postJson(
      '/organizations/$organizationId/subscription/plan',
      body: {'plan': plan.apiValue, 'paymentMethodId': ?paymentMethodId},
    );
    return SubscriptionDto.fromJson(data as JSON);
  }

  /// `POST /organizations/{organizationId}/subscription/downgrade`
  Future<SubscriptionDto> downgrade(String organizationId) async {
    final data = await client.postJson(
      '/organizations/$organizationId/subscription/downgrade',
    );
    return SubscriptionDto.fromJson(data as JSON);
  }

  /// `POST /organizations/{organizationId}/subscription/resume`
  Future<SubscriptionDto> resume(String organizationId) async {
    final data = await client.postJson(
      '/organizations/$organizationId/subscription/resume',
    );
    return SubscriptionDto.fromJson(data as JSON);
  }
}
