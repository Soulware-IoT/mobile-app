import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cocina360/features/organization/domain/repositories/organization_repository.dart';
import 'package:cocina360/features/organization/presentation/cubit/create_organization_state.dart';

class CreateOrganizationCubit extends Cubit<CreateOrganizationState> {
  final OrganizationRepository repository;

  CreateOrganizationCubit(this.repository)
    : super(const CreateOrganizationInitial());

  Future<void> save({
    required String name,
    String? imageUrl,
    String? addressLineOne,
    String? addressLineTwo,
    String? addressReference,
  }) async {
    emit(const CreateOrganizationSaving());
    try {
      final organization = await repository.createOrganization(
        name: name,
        imageUrl: imageUrl,
        addressLineOne: addressLineOne,
        addressLineTwo: addressLineTwo,
        addressReference: addressReference,
      );
      emit(CreateOrganizationSuccess(organization));
    } catch (e) {
      emit(CreateOrganizationFailure(e));
    }
  }
}
