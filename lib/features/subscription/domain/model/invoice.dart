/// A billed (or in-progress) Stripe invoice, read-only, most recent first.
class Invoice {
  /// Stripe's human-readable invoice number (e.g. `A1B2C3D4-0001`). May be
  /// null for draft invoices.
  final String? number;

  /// Stripe invoice status: `draft`, `open`, `paid`, `void` or `uncollectible`.
  final String status;

  /// Amount paid, in the currency's minor units (cents for USD).
  final int amountPaid;

  /// Lowercase ISO currency code as Stripe reports it (e.g. `usd`).
  final String currency;

  final DateTime? createdAt;

  /// Stripe-hosted invoice page; null for draft invoices.
  final String? hostedInvoiceUrl;

  /// Direct PDF download; null for draft invoices.
  final String? invoicePdfUrl;

  const Invoice({
    required this.number,
    required this.status,
    required this.amountPaid,
    required this.currency,
    required this.createdAt,
    this.hostedInvoiceUrl,
    this.invoicePdfUrl,
  });

  bool get isPaid => status == 'paid';
}
