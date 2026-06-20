import 'package:cocina360/features/organization/domain/model/organization.dart';

sealed class EditOrganizationState {
  const EditOrganizationState();
}

final class EditOrganizationInitial extends EditOrganizationState {
  const EditOrganizationInitial();
}

final class EditOrganizationSaving extends EditOrganizationState {
  const EditOrganizationSaving();
}

final class EditOrganizationSuccess extends EditOrganizationState {
  final Organization organization;

  const EditOrganizationSuccess(this.organization);
}

final class EditOrganizationFailure extends EditOrganizationState {
  final String message;

  const EditOrganizationFailure(this.message);
}
