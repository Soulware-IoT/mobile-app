import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cocina360/features/organization/domain/model/organization.dart';
import 'package:cocina360/features/organization/presentation/cubit/edit_organization_cubit.dart';
import 'package:cocina360/features/organization/presentation/cubit/edit_organization_state.dart';
import 'package:cocina360/features/organization/presentation/cubit/organization_cubit.dart';
import 'package:cocina360/l10n/app_localizations.dart';
import 'package:cocina360/shared/presentation/error/localized_error.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.editOrganizationTitle)),
      body: BlocConsumer<EditOrganizationCubit, EditOrganizationState>(
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
              SnackBar(content: Text(localizedError(context, state.error))),
            );
          }
        },
        builder: (context, state) {
          final saving = state is EditOrganizationSaving;
          return AbsorbPointer(
            absorbing: saving,
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
                            : Text(l10n.saveChanges),
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
