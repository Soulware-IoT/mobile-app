import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cocina360/features/organization/domain/repositories/organization_repository.dart';
import 'package:cocina360/features/organization/presentation/cubit/delete_organization_state.dart';

class DeleteOrganizationCubit extends Cubit<DeleteOrganizationState> {
  final OrganizationRepository repository;

  DeleteOrganizationCubit(this.repository)
    : super(const DeleteOrganizationInitial());

  Future<void> delete(String organizationId) async {
    emit(const DeleteOrganizationDeleting());
    try {
      await repository.deleteOrganization(organizationId);
      emit(const DeleteOrganizationSuccess());
    } catch (e) {
      emit(DeleteOrganizationFailure(e));
    }
  }
}
