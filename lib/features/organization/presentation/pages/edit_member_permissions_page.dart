import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cocina360/features/organization/domain/model/member_role.dart';
import 'package:cocina360/features/organization/domain/model/organization_member.dart';
import 'package:cocina360/features/organization/presentation/cubit/edit_member_permissions_cubit.dart';
import 'package:cocina360/features/organization/presentation/cubit/edit_member_permissions_state.dart';
import 'package:cocina360/features/organization/presentation/cubit/organization_cubit.dart';
import 'package:cocina360/features/organization/presentation/cubit/organization_state.dart';
import 'package:cocina360/l10n/app_localizations.dart';
import 'package:cocina360/shared/presentation/error/localized_error.dart';
import 'package:cocina360/shared/presentation/theme/theme.dart';

class EditMemberPermissionsPage extends StatefulWidget {
  final OrganizationMember member;

  const EditMemberPermissionsPage({super.key, required this.member});

  @override
  State<EditMemberPermissionsPage> createState() =>
      _EditMemberPermissionsPageState();
}

class _EditMemberPermissionsPageState extends State<EditMemberPermissionsPage> {
  late MemberRole _security;
  late MemberRole _organization;
  late MemberRole _internalControl;

  @override
  void initState() {
    super.initState();
    _security = widget.member.security;
    _organization = widget.member.organization;
    _internalControl = widget.member.internalControl;
  }

  void _save() {
    final orgState = context.read<OrganizationCubit>().state;
    if (orgState is! OrganizationLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.organizationNotDetermined,
          ),
        ),
      );
      return;
    }

    context.read<EditMemberPermissionsCubit>().save(
      organizationId: orgState.organization.id,
      memberId: widget.member.id,
      security: _security,
      organization: _organization,
      internalControl: _internalControl,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.editPermissions)),
      body: BlocConsumer<EditMemberPermissionsCubit, EditMemberPermissionsState>(
        listener: (context, state) {
          if (state is EditMemberPermissionsSuccess) {
            context.read<OrganizationCubit>().applyUpdatedMember(state.member);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.permissionsUpdated)),
            );
            context.pop(state.member);
          } else if (state is EditMemberPermissionsFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(localizedError(context, state.error))),
            );
          }
        },
        builder: (context, state) {
          final saving = state is EditMemberPermissionsSaving;
          return AbsorbPointer(
            absorbing: saving,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              children: [
                Text(
                  widget.member.fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 24),
                _RoleField(
                  label: l10n.permissionSecurity,
                  value: _security,
                  enabled: !saving,
                  onChanged: (v) => setState(() => _security = v),
                ),
                const SizedBox(height: 16),
                _RoleField(
                  label: l10n.permissionOrganization,
                  value: _organization,
                  enabled: !saving,
                  onChanged: (v) => setState(() => _organization = v),
                ),
                const SizedBox(height: 16),
                _RoleField(
                  label: l10n.permissionInternalControl,
                  value: _internalControl,
                  enabled: !saving,
                  onChanged: (v) => setState(() => _internalControl = v),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.seedColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.saveChanges),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RoleField extends StatelessWidget {
  final String label;
  final MemberRole value;
  final bool enabled;
  final ValueChanged<MemberRole> onChanged;

  const _RoleField({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<MemberRole>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      onChanged: enabled ? (v) => v == null ? null : onChanged(v) : null,
      items: [
        for (final role in MemberRole.values)
          DropdownMenuItem(value: role, child: Text(role.label)),
      ],
    );
  }
}
