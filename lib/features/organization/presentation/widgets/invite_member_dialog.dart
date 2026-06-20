import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cocina360/features/organization/domain/repositories/organization_repository.dart';
import 'package:cocina360/features/organization/presentation/cubit/invitations_cubit.dart';
import 'package:cocina360/features/organization/presentation/cubit/invite_member_cubit.dart';
import 'package:cocina360/features/organization/presentation/cubit/invite_member_state.dart';
import 'package:cocina360/l10n/app_localizations.dart';
import 'package:cocina360/shared/presentation/error/localized_error.dart';

/// Opens the "invite member" dialog. On success it refreshes the pending
/// invitations list (via the page's [InvitationsCubit]) and shows a snackbar.
Future<void> showInviteMemberDialog(
  BuildContext context, {
  required String organizationId,
}) {
  final repository = context.read<OrganizationRepository>();
  final invitationsCubit = context.read<InvitationsCubit>();

  return showDialog<void>(
    context: context,
    builder: (_) => BlocProvider(
      create: (_) => InviteMemberCubit(repository),
      child: _InviteMemberDialog(
        organizationId: organizationId,
        onInvited: () => invitationsCubit.load(organizationId),
      ),
    ),
  );
}

class _InviteMemberDialog extends StatefulWidget {
  final String organizationId;
  final VoidCallback onInvited;

  const _InviteMemberDialog({
    required this.organizationId,
    required this.onInvited,
  });

  @override
  State<_InviteMemberDialog> createState() => _InviteMemberDialogState();
}

class _InviteMemberDialogState extends State<_InviteMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<InviteMemberCubit>().invite(
      organizationId: widget.organizationId,
      email: _emailController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocConsumer<InviteMemberCubit, InviteMemberState>(
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        if (state is InviteMemberSuccess) {
          widget.onInvited();
          Navigator.of(context).pop();
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.invitationSent)),
          );
        } else if (state is InviteMemberFailure) {
          messenger.showSnackBar(
            SnackBar(content: Text(localizedError(context, state.error))),
          );
        }
      },
      builder: (context, state) {
        final sending = state is InviteMemberSending;
        return AlertDialog(
          title: Text(l10n.inviteMemberTitle),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _emailController,
              enabled: !sending,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.authEmailLabel,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              onFieldSubmitted: (_) => sending ? null : _submit(),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return l10n.inviteEmailRequired;
                }
                if (!v.contains('@')) return l10n.authEmailInvalid;
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: sending ? null : () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: sending ? null : _submit,
              child: sending
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : Text(l10n.invite),
            ),
          ],
        );
      },
    );
  }
}
