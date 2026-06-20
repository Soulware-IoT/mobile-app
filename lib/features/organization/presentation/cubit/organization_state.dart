import 'package:cocina360/features/organization/domain/model/organization.dart';
import 'package:cocina360/features/organization/domain/model/organization_member.dart';

sealed class OrganizationState {
  const OrganizationState();
}

final class OrganizationInitial extends OrganizationState {
  const OrganizationInitial();
}

final class OrganizationLoading extends OrganizationState {
  const OrganizationLoading();
}

final class OrganizationLoaded extends OrganizationState {
  final Organization organization;
  final List<OrganizationMember> members;

  const OrganizationLoaded(this.organization, this.members);
}

/// The user is authenticated but belongs to no organization yet.
final class OrganizationEmpty extends OrganizationState {
  const OrganizationEmpty();
}

final class OrganizationError extends OrganizationState {
  /// The raw error, rendered to a localized string by the page via
  /// `localizedError`.
  final Object error;

  const OrganizationError(this.error);
}
