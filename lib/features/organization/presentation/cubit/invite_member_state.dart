sealed class InviteMemberState {
  const InviteMemberState();
}

final class InviteMemberInitial extends InviteMemberState {
  const InviteMemberInitial();
}

final class InviteMemberSending extends InviteMemberState {
  const InviteMemberSending();
}

final class InviteMemberSuccess extends InviteMemberState {
  const InviteMemberSuccess();
}

final class InviteMemberFailure extends InviteMemberState {
  final Object error;

  const InviteMemberFailure(this.error);
}
