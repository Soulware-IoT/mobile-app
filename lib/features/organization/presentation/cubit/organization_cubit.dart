import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cocina360/features/organization/domain/model/organization.dart';
import 'package:cocina360/features/organization/domain/model/organization_member.dart';
import 'package:cocina360/features/organization/domain/repositories/organization_repository.dart';
import 'package:cocina360/features/organization/presentation/cubit/organization_state.dart';

class OrganizationCubit extends Cubit<OrganizationState> {
  final OrganizationRepository repository;

  OrganizationCubit(this.repository) : super(const OrganizationInitial());

  Future<void> load(String userId) async {
    emit(const OrganizationLoading());
    try {
      final result = await repository.getPrimaryOrganization(userId);
      if (result == null) {
        emit(const OrganizationEmpty());
        return;
      }
      emit(OrganizationLoaded(result.organization, result.members));
    } catch (e) {
      emit(OrganizationError(e));
    }
  }

  /// Loads a specific organization (by id) as the active one — used when the
  /// user switches organizations from the drawer.
  Future<void> selectOrganization(String organizationId) async {
    emit(const OrganizationLoading());
    try {
      final result =
          await repository.getOrganizationWithMembers(organizationId);
      emit(OrganizationLoaded(result.organization, result.members));
    } catch (e) {
      emit(OrganizationError(e));
    }
  }

  /// Swaps the organization in the current loaded state after an edit, keeping
  /// the already-loaded members (avoids a refetch).
  void applyUpdatedOrganization(Organization organization) {
    final current = state;
    if (current is OrganizationLoaded) {
      emit(OrganizationLoaded(organization, current.members));
    }
  }

  /// Replaces a member (by id) in the loaded list after its permissions change.
  void applyUpdatedMember(OrganizationMember member) {
    final current = state;
    if (current is OrganizationLoaded) {
      final members = [
        for (final m in current.members) m.id == member.id ? member : m,
      ];
      emit(OrganizationLoaded(current.organization, members));
    }
  }

  /// Drops a member (by id) from the loaded list after its removal.
  void applyRemovedMember(String memberId) {
    final current = state;
    if (current is OrganizationLoaded) {
      final members = current.members.where((m) => m.id != memberId).toList();
      emit(OrganizationLoaded(current.organization, members));
    }
  }

  /// Clears the active organization after it's deleted. Callers should follow
  /// up with [selectOrganization] if the user has another one, since a fresh
  /// [load] would risk picking the just-deleted org back up from the JWT's
  /// (not-yet-refreshed) membership claim.
  void clear() => emit(const OrganizationEmpty());
}
