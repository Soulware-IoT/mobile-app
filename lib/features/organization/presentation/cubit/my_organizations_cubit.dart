import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cocina360/features/organization/domain/repositories/organization_repository.dart';
import 'package:cocina360/features/organization/presentation/cubit/my_organizations_state.dart';

/// Holds the organizations the current user belongs to, for the drawer list.
class MyOrganizationsCubit extends Cubit<MyOrganizationsState> {
  final OrganizationRepository repository;

  MyOrganizationsCubit(this.repository)
    : super(const MyOrganizationsInitial());

  Future<void> load(String profileId) async {
    emit(const MyOrganizationsLoading());
    try {
      final organizations = await repository.getMyOrganizations(profileId);
      emit(MyOrganizationsLoaded(organizations));
    } catch (e) {
      emit(MyOrganizationsError(e));
    }
  }
}
