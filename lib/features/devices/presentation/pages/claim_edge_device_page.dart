import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cocina360/features/devices/presentation/cubit/claim_edge_device_cubit.dart';
import 'package:cocina360/features/devices/presentation/cubit/claim_edge_device_state.dart';
import 'package:cocina360/l10n/app_localizations.dart';
import 'package:cocina360/shared/presentation/error/localized_error.dart';

/// Claims a factory-provisioned edge gateway into the organization by its
/// code (read off the device). An organization has at most one edge device.
class ClaimEdgeDevicePage extends StatefulWidget {
  final String organizationId;

  const ClaimEdgeDevicePage({super.key, required this.organizationId});

  @override
  State<ClaimEdgeDevicePage> createState() => _ClaimEdgeDevicePageState();
}

class _ClaimEdgeDevicePageState extends State<ClaimEdgeDevicePage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ClaimEdgeDeviceCubit>().claim(
      organizationId: widget.organizationId,
      code: _codeController.text.trim(),
      name: _nameController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.claimEdgeDeviceTitle)),
      body: BlocConsumer<ClaimEdgeDeviceCubit, ClaimEdgeDeviceState>(
        listener: (context, state) {
          if (state is ClaimEdgeDeviceSuccess) {
            context.pop(true);
          } else if (state is ClaimEdgeDeviceFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(localizedError(context, state.error))),
            );
          }
        },
        builder: (context, state) {
          final claiming = state is ClaimEdgeDeviceClaiming;
          return AbsorbPointer(
            absorbing: claiming,
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  Text(
                    l10n.claimEdgeDeviceIntro,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _codeController,
                    enabled: !claiming,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: l10n.claimDeviceCodeLabel,
                      prefixIcon: const Icon(Icons.qr_code_outlined),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.validationRequired
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    enabled: !claiming,
                    decoration: InputDecoration(
                      labelText: l10n.deviceNameLabel,
                      prefixIcon: const Icon(Icons.router_outlined),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.deviceNameRequired
                        : null,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: claiming ? null : _submit,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: claiming
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(l10n.claimDeviceSubmit),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
