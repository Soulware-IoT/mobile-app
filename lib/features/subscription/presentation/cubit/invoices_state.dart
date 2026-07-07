import 'package:cocina360/features/subscription/domain/model/invoice.dart';

sealed class InvoicesState {
  const InvoicesState();
}

final class InvoicesInitial extends InvoicesState {
  const InvoicesInitial();
}

final class InvoicesLoading extends InvoicesState {
  const InvoicesLoading();
}

final class InvoicesLoaded extends InvoicesState {
  final List<Invoice> invoices;

  const InvoicesLoaded(this.invoices);
}

final class InvoicesError extends InvoicesState {
  final Object error;

  const InvoicesError(this.error);
}
