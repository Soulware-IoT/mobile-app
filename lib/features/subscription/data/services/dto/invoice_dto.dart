import 'package:cocina360/features/subscription/domain/model/invoice.dart';
import 'package:cocina360/shared/data/types/json.dart';

/// Maps the backend `InvoiceResponse` (served through the api-gw) into the
/// [Invoice] domain model.
class InvoiceDto {
  final String? number;
  final String? status;
  final int amountPaid;
  final String? currency;
  final String? createdAt;
  final String? hostedInvoiceUrl;
  final String? invoicePdfUrl;

  const InvoiceDto({
    this.number,
    this.status,
    this.amountPaid = 0,
    this.currency,
    this.createdAt,
    this.hostedInvoiceUrl,
    this.invoicePdfUrl,
  });

  factory InvoiceDto.fromJson(JSON json) {
    return InvoiceDto(
      number: json['number'] as String?,
      status: json['status'] as String?,
      amountPaid: (json['amountPaid'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String?,
      createdAt: json['createdAt'] as String?,
      hostedInvoiceUrl: json['hostedInvoiceUrl'] as String?,
      invoicePdfUrl: json['invoicePdfUrl'] as String?,
    );
  }

  Invoice toDomain() {
    return Invoice(
      number: number,
      status: status ?? 'draft',
      amountPaid: amountPaid,
      currency: currency ?? 'usd',
      createdAt: createdAt == null ? null : DateTime.tryParse(createdAt!),
      hostedInvoiceUrl: hostedInvoiceUrl,
      invoicePdfUrl: invoicePdfUrl,
    );
  }
}
