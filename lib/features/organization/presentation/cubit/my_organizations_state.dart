import 'package:cocina360/features/organization/domain/model/organization.dart';

sealed class MyOrganizationsState {
  const MyOrganizationsState();
}

final class MyOrganizationsInitial extends MyOrganizationsState {
  const MyOrganizationsInitial();
}

final class MyOrganizationsLoading extends MyOrganizationsState {
  const MyOrganizationsLoading();
}

final class MyOrganizationsLoaded extends MyOrganizationsState {
  final List<Organization> organizations;

  const MyOrganizationsLoaded(this.organizations);
}

final class MyOrganizationsError extends MyOrganizationsState {
  /// The raw error, rendered to a localized string by the widget via
  /// `localizedError`.
  final Object error;

  const MyOrganizationsError(this.error);
}
