import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cocina360/features/organization/domain/repositories/organization_repository.dart';
import 'package:cocina360/features/organization/presentation/cubit/organization_state.dart';

class OrganizationCubit extends Cubit<OrganizationState> {
  final OrganizationRepository repository;

  OrganizationCubit(this.repository) : super(const OrganizationInitial());

  Future<void> load(String userId) async {
    emit(const OrganizationLoading());
    try {
      final result = await repository.getPrimaryOrganization(userId);
      if (result == null) {
        emit(const OrganizationEmpty());
        return;
      }
      emit(OrganizationLoaded(result.organization, result.members));
    } catch (e) {
      emit(OrganizationError(e.toString()));
    }
  }
}
