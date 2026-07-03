import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cocina360/features/organization/domain/model/organization.dart';
import 'package:cocina360/features/organization/presentation/cubit/delete_organization_cubit.dart';
import 'package:cocina360/features/organization/presentation/cubit/delete_organization_state.dart';
import 'package:cocina360/features/organization/presentation/cubit/edit_organization_cubit.dart';
import 'package:cocina360/features/organization/presentation/cubit/edit_organization_state.dart';
import 'package:cocina360/features/organization/presentation/cubit/my_organizations_cubit.dart';
import 'package:cocina360/features/organization/presentation/cubit/my_organizations_state.dart';
import 'package:cocina360/features/organization/presentation/cubit/organization_cubit.dart';
import 'package:cocina360/l10n/app_localizations.dart';
import 'package:cocina360/shared/presentation/error/localized_error.dart';
import 'package:cocina360/shared/presentation/router/app_router.dart';
import 'package:cocina360/shared/presentation/session/auth/auth_cubit.dart';
import 'package:cocina360/shared/presentation/session/auth/auth_state.dart';
import 'package:cocina360/shared/presentation/theme/theme.dart';

class EditOrganizationPage extends StatefulWidget {
  final Organization organization;

  const EditOrganizationPage({super.key, required this.organization});

  @override
  State<EditOrganizationPage> createState() => _EditOrganizationPageState();
}

class _EditOrganizationPageState extends State<EditOrganizationPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final org = widget.organization;
    _nameController = TextEditingController(text: org.name);
    _addressController = TextEditingController(text: org.addressLineOne ?? '');
    _notesController = TextEditingController(text: org.addressReference ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final org = widget.organization;
    context.read<EditOrganizationCubit>().save(
      organizationId: org.id,
      name: _nameController.text.trim(),
      // Preserve fields not exposed by this form so the PATCH doesn't wipe them.
      imageUrl: org.imageUrl,
      addressLineTwo: org.addressLineTwo,
      addressLineOne: _addressController.text.trim(),
      addressReference: _notesController.text.trim(),
    );
  }

  Future<void> _deleteOrganization() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteOrganizationConfirmTitle),
        content: Text(
          l10n.deleteOrganizationConfirmBody(widget.organization.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<DeleteOrganizationCubit>().delete(
        widget.organization.id,
      );
    }
  }

  /// The just-deleted membership may linger in the JWT's (not-yet-refreshed)
  /// claims, so the next active organization is picked from the live,
  /// API-backed list rather than the JWT-claims-based primary-organization
  /// lookup.
  Future<void> _afterDelete() async {
    final userId = switch (context.read<AuthCubit>().state) {
      Authenticated(:final userId) => userId,
      OfflineAuthenticated(:final userId) => userId,
      _ => null,
    };
    if (userId == null) return;

    final myOrgsCubit = context.read<MyOrganizationsCubit>();
    await myOrgsCubit.load(userId);
    if (!mounted) return;

    final remaining = switch (myOrgsCubit.state) {
      MyOrganizationsLoaded(:final organizations) => organizations,
      _ => const <Organization>[],
    };

    final organizationCubit = context.read<OrganizationCubit>();
    if (remaining.isNotEmpty) {
      await organizationCubit.selectOrganization(remaining.first.id);
    } else {
      organizationCubit.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isOwner = switch (context.watch<AuthCubit>().state) {
      Authenticated(:final userId) => userId == widget.organization.ownedBy,
      OfflineAuthenticated(:final userId) =>
        userId == widget.organization.ownedBy,
      _ => false,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editOrganizationTitle)),
      body: MultiBlocListener(
        listeners: [
          BlocListener<EditOrganizationCubit, EditOrganizationState>(
            listener: (context, state) {
              if (state is EditOrganizationSuccess) {
                context.read<OrganizationCubit>().applyUpdatedOrganization(
                  state.organization,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.organizationUpdated)),
                );
                context.pop();
              } else if (state is EditOrganizationFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(localizedError(context, state.error)),
                  ),
                );
              }
            },
          ),
          BlocListener<DeleteOrganizationCubit, DeleteOrganizationState>(
            listener: (context, state) async {
              if (state is DeleteOrganizationSuccess) {
                await _afterDelete();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.organizationDeleted)),
                  );
                  context.go(AppRoutes.home);
                }
              } else if (state is DeleteOrganizationFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(localizedError(context, state.error)),
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<EditOrganizationCubit, EditOrganizationState>(
          builder: (context, state) {
            final saving = state is EditOrganizationSaving;
            return BlocBuilder<
              DeleteOrganizationCubit,
              DeleteOrganizationState
            >(
              builder: (context, deleteState) {
                final deleting = deleteState is DeleteOrganizationDeleting;
                final busy = saving || deleting;
                return AbsorbPointer(
                  absorbing: busy,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    children: [
                      _ImageCard(imageUrl: widget.organization.imageUrl),
                      const SizedBox(height: 16),
                      _DetailsCard(
                        formKey: _formKey,
                        nameController: _nameController,
                        addressController: _addressController,
                        notesController: _notesController,
                        enabled: !busy,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: busy ? null : () => context.pop(),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(l10n.cancel),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton(
                              onPressed: busy ? null : _save,
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
                          ),
                        ],
                      ),
                      if (isOwner) ...[
                        const SizedBox(height: 32),
                        Divider(
                          color: Theme.of(
                            context,
                          ).colorScheme.error.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: busy ? null : _deleteOrganization,
                          icon: deleting
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.delete_outline, size: 18),
                          label: Text(l10n.deleteOrganizationTitle),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                            ),
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final String? imageUrl;

  const _ImageCard({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 180,
            width: double.infinity,
            child: hasImage
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _placeholder(theme),
                  )
                : _placeholder(theme),
          ),
          // Image upload is not implemented yet (no upload endpoint); the button
          // is a disabled placeholder.
          FilledButton.tonalIcon(
            onPressed: null,
            icon: const Icon(Icons.upload_outlined, size: 18),
            label: Text(AppLocalizations.of(context)!.uploadNewImage),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(ThemeData theme) => Container(
    color: theme.colorScheme.surfaceContainerHighest,
    child: Icon(
      Icons.business_outlined,
      size: 56,
      color: theme.colorScheme.onSurfaceVariant,
    ),
  );
}

class _DetailsCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController notesController;
  final bool enabled;

  const _DetailsCard({
    required this.formKey,
    required this.nameController,
    required this.addressController,
    required this.notesController,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: nameController,
                enabled: enabled,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.organizationNameLabel,
                  prefixIcon: const Icon(Icons.apartment_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return l10n.organizationNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: addressController,
                enabled: enabled,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.physicalLocationLabel,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: notesController,
                enabled: enabled,
                minLines: 3,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  labelText: l10n.directionsNotesLabel,
                  alignLabelWithHint: true,
                  prefixIcon: const Icon(Icons.navigation_outlined),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
