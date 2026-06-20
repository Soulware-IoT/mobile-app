import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cocina360/features/organization/domain/repositories/organization_repository.dart';
import 'package:cocina360/features/organization/presentation/cubit/invitations_state.dart';

class InvitationsCubit extends Cubit<InvitationsState> {
  final OrganizationRepository repository;

  InvitationsCubit(this.repository) : super(const InvitationsInitial());

  Future<void> load(String organizationId) async {
    emit(const InvitationsLoading());
    try {
      final invitations = await repository.getInvitations(organizationId);
      emit(InvitationsLoaded(invitations));
    } catch (e) {
      emit(InvitationsError(e));
    }
  }
}
