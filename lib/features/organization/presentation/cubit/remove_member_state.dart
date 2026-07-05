sealed class RemoveMemberState {
  const RemoveMemberState();
}

final class RemoveMemberInitial extends RemoveMemberState {
  const RemoveMemberInitial();
}

final class RemoveMemberRemoving extends RemoveMemberState {
  const RemoveMemberRemoving();
}

final class RemoveMemberSuccess extends RemoveMemberState {
  const RemoveMemberSuccess();
}

final class RemoveMemberFailure extends RemoveMemberState {
  final Object error;

  const RemoveMemberFailure(this.error);
}
