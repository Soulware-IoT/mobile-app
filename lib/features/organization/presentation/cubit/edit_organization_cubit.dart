import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cocina360/features/organization/domain/repositories/organization_repository.dart';
import 'package:cocina360/features/organization/presentation/cubit/edit_organization_state.dart';

class EditOrganizationCubit extends Cubit<EditOrganizationState> {
  final OrganizationRepository repository;

  EditOrganizationCubit(this.repository)
    : super(const EditOrganizationInitial());

  Future<void> save({
    required String organizationId,
    required String name,
    String? imageUrl,
    String? addressLineOne,
    String? addressLineTwo,
    String? addressReference,
  }) async {
    emit(const EditOrganizationSaving());
    try {
      final organization = await repository.updateOrganization(
        organizationId: organizationId,
        name: name,
        imageUrl: imageUrl,
        addressLineOne: addressLineOne,
        addressLineTwo: addressLineTwo,
        addressReference: addressReference,
      );
      emit(EditOrganizationSuccess(organization));
    } catch (e) {
      emit(EditOrganizationFailure(e.toString()));
    }
  }
}
