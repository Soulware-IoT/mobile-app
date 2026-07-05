sealed class DeleteOrganizationState {
  const DeleteOrganizationState();
}

final class DeleteOrganizationInitial extends DeleteOrganizationState {
  const DeleteOrganizationInitial();
}

final class DeleteOrganizationDeleting extends DeleteOrganizationState {
  const DeleteOrganizationDeleting();
}

final class DeleteOrganizationSuccess extends DeleteOrganizationState {
  const DeleteOrganizationSuccess();
}

final class DeleteOrganizationFailure extends DeleteOrganizationState {
  final Object error;

  const DeleteOrganizationFailure(this.error);
}
