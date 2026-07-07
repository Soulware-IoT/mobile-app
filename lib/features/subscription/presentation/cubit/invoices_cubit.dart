import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cocina360/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:cocina360/features/subscription/presentation/cubit/invoices_state.dart';

/// Loads the organization's invoice history (owner only — see repository).
class InvoicesCubit extends Cubit<InvoicesState> {
  final SubscriptionRepository repository;

  InvoicesCubit(this.repository) : super(const InvoicesInitial());

  Future<void> load(String organizationId) async {
    emit(const InvoicesLoading());
    try {
      final invoices = await repository.listInvoices(organizationId);
      emit(InvoicesLoaded(invoices));
    } catch (e) {
      emit(InvoicesError(e));
    }
  }
}
