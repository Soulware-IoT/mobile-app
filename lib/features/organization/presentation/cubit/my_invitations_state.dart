import 'package:cocina360/features/organization/domain/model/invitation.dart';

sealed class MyInvitationsState {
  const MyInvitationsState();
}

final class MyInvitationsInitial extends MyInvitationsState {
  const MyInvitationsInitial();
}

final class MyInvitationsLoading extends MyInvitationsState {
  const MyInvitationsLoading();
}

final class MyInvitationsLoaded extends MyInvitationsState {
  final List<Invitation> invitations;

  /// Id of the invitation currently being accepted/declined (for a per-card
  /// spinner), or null when idle.
  final String? processingId;

  const MyInvitationsLoaded(this.invitations, {this.processingId});
}

/// Initial-load failure (full-screen error with retry).
final class MyInvitationsError extends MyInvitationsState {
  final Object error;

  const MyInvitationsError(this.error);
}

/// Accept/decline failure: keeps the current list so the page can show a
/// snackbar without losing the rendered list.
final class MyInvitationsActionError extends MyInvitationsState {
  final List<Invitation> invitations;
  final Object error;

  const MyInvitationsActionError(this.invitations, this.error);
}
