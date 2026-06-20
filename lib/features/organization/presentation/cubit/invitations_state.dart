import 'package:cocina360/features/organization/domain/model/invitation.dart';

sealed class InvitationsState {
  const InvitationsState();
}

final class InvitationsInitial extends InvitationsState {
  const InvitationsInitial();
}

final class InvitationsLoading extends InvitationsState {
  const InvitationsLoading();
}

final class InvitationsLoaded extends InvitationsState {
  final List<Invitation> invitations;

  const InvitationsLoaded(this.invitations);

  /// Only the still-pending invitations, for the "pending" section.
  List<Invitation> get pending =>
      invitations.where((i) => i.status == InvitationStatus.pending).toList();
}

final class InvitationsError extends InvitationsState {
  final Object error;

  const InvitationsError(this.error);
}
