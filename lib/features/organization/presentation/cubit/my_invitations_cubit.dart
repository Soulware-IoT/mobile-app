import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cocina360/features/organization/domain/model/invitation.dart';
import 'package:cocina360/features/organization/domain/repositories/organization_repository.dart';
import 'package:cocina360/features/organization/presentation/cubit/my_invitations_state.dart';

class MyInvitationsCubit extends Cubit<MyInvitationsState> {
  final OrganizationRepository repository;

  MyInvitationsCubit(this.repository) : super(const MyInvitationsInitial());

  Future<void> load(String profileId) async {
    emit(const MyInvitationsLoading());
    try {
      final invitations = await repository.getMyInvitations(profileId);
      emit(MyInvitationsLoaded(invitations));
    } catch (e) {
      emit(MyInvitationsError(e));
    }
  }

  Future<void> accept(String invitationId, String profileId) =>
      _respond(invitationId, profileId, accept: true);

  Future<void> decline(String invitationId, String profileId) =>
      _respond(invitationId, profileId, accept: false);

  Future<void> _respond(
    String invitationId,
    String profileId, {
    required bool accept,
  }) async {
    final current = state;
    final currentList = current is MyInvitationsLoaded
        ? current.invitations
        : const <Invitation>[];

    emit(MyInvitationsLoaded(currentList, processingId: invitationId));
    try {
      if (accept) {
        await repository.acceptInvitation(invitationId);
      } else {
        await repository.declineInvitation(invitationId);
      }
      final fresh = await repository.getMyInvitations(profileId);
      emit(MyInvitationsActionSuccess(fresh, accepted: accept));
      emit(MyInvitationsLoaded(fresh));
    } catch (e) {
      emit(MyInvitationsActionError(currentList, e));
    }
  }
}
