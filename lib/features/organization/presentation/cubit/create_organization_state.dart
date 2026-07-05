import 'package:cocina360/features/organization/domain/model/organization.dart';

sealed class CreateOrganizationState {
  const CreateOrganizationState();
}

final class CreateOrganizationInitial extends CreateOrganizationState {
  const CreateOrganizationInitial();
}

final class CreateOrganizationSaving extends CreateOrganizationState {
  const CreateOrganizationSaving();
}

final class CreateOrganizationSuccess extends CreateOrganizationState {
  final Organization organization;

  const CreateOrganizationSuccess(this.organization);
}

final class CreateOrganizationFailure extends CreateOrganizationState {
  final Object error;

  const CreateOrganizationFailure(this.error);
}
