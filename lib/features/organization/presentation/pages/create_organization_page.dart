import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cocina360/features/organization/presentation/cubit/create_organization_cubit.dart';
import 'package:cocina360/features/organization/presentation/cubit/create_organization_state.dart';
import 'package:cocina360/features/organization/presentation/cubit/my_organizations_cubit.dart';
import 'package:cocina360/features/organization/presentation/cubit/organization_cubit.dart';
import 'package:cocina360/l10n/app_localizations.dart';
import 'package:cocina360/shared/presentation/error/localized_error.dart';
import 'package:cocina360/shared/presentation/session/auth/auth_cubit.dart';
import 'package:cocina360/shared/presentation/session/auth/auth_state.dart';
import 'package:cocina360/shared/presentation/theme/theme.dart';

/// Creates a new organization (the current user becomes its owner) and makes
/// it the active one on the Organization screen.
class CreateOrganizationPage extends StatefulWidget {
  const CreateOrganizationPage({super.key});

  @override
  State<CreateOrganizationPage> createState() =>
      _CreateOrganizationPageState();
}

class _CreateOrganizationPageState extends State<CreateOrganizationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<CreateOrganizationCubit>().save(
      name: _nameController.text.trim(),
      addressLineOne: _addressController.text.trim(),
      addressReference: _notesController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.createOrganizationTitle)),
      body: BlocConsumer<CreateOrganizationCubit, CreateOrganizationState>(
        listener: (context, state) {
          if (state is CreateOrganizationSuccess) {
            // The just-created membership isn't in the JWT's custom claims
            // yet (it only refreshes on the next token issuance), so the
            // active organization is set directly by id rather than through
            // the JWT-claims-based primary-organization lookup.
            context.read<OrganizationCubit>().selectOrganization(
              state.organization.id,
            );
            final userId = switch (context.read<AuthCubit>().state) {
              Authenticated(:final userId) => userId,
              OfflineAuthenticated(:final userId) => userId,
              _ => null,
            };
            if (userId != null) {
              context.read<MyOrganizationsCubit>().load(userId);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.organizationCreated)),
            );
            context.pop();
          } else if (state is CreateOrganizationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(localizedError(context, state.error))),
            );
          }
        },
        builder: (context, state) {
          final saving = state is CreateOrganizationSaving;
          return AbsorbPointer(
            absorbing: saving,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                _DetailsCard(
                  formKey: _formKey,
                  nameController: _nameController,
                  addressController: _addressController,
                  notesController: _notesController,
                  enabled: !saving,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: saving ? null : () => context.pop(),
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
                            : Text(l10n.create),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
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
                autofocus: true,
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
