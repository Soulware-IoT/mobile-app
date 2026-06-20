import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cocina360/features/organization/domain/model/invitation.dart';
import 'package:cocina360/features/organization/presentation/cubit/my_invitations_cubit.dart';
import 'package:cocina360/features/organization/presentation/cubit/my_invitations_state.dart';
import 'package:cocina360/features/organization/presentation/widgets/my_invitation_card.dart';
import 'package:cocina360/shared/presentation/session/auth/auth_cubit.dart';
import 'package:cocina360/shared/presentation/session/auth/auth_state.dart';

class MyInvitationsPage extends StatefulWidget {
  const MyInvitationsPage({super.key});

  @override
  State<MyInvitationsPage> createState() => _MyInvitationsPageState();
}

class _MyInvitationsPageState extends State<MyInvitationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  String? get _userId => switch (context.read<AuthCubit>().state) {
    Authenticated(:final userId) => userId,
    OfflineAuthenticated(:final userId) => userId,
    _ => null,
  };

  void _load() {
    final userId = _userId;
    if (userId != null) {
      context.read<MyInvitationsCubit>().load(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis invitaciones')),
      body: BlocConsumer<MyInvitationsCubit, MyInvitationsState>(
        listener: (context, state) {
          if (state is MyInvitationsActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No se pudo completar: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            MyInvitationsInitial() ||
            MyInvitationsLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            MyInvitationsError(:final message) => _ErrorView(
              message: message,
              onRetry: _load,
            ),
            MyInvitationsLoaded(:final invitations, :final processingId) =>
              _List(invitations: invitations, processingId: processingId),
            MyInvitationsActionError(:final invitations) =>
              _List(invitations: invitations, processingId: null),
          };
        },
      ),
    );
  }
}

class _List extends StatelessWidget {
  final List<Invitation> invitations;
  final String? processingId;

  const _List({required this.invitations, required this.processingId});

  @override
  Widget build(BuildContext context) {
    if (invitations.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mark_email_read_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No tienes invitaciones.', textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    final userId = switch (context.read<AuthCubit>().state) {
      Authenticated(:final userId) => userId,
      OfflineAuthenticated(:final userId) => userId,
      _ => null,
    };
    final cubit = context.read<MyInvitationsCubit>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        for (final inv in invitations)
          MyInvitationCard(
            invitation: inv,
            processing: processingId == inv.id,
            onAccept: userId == null
                ? null
                : () => cubit.accept(inv.id, userId),
            onDecline: userId == null
                ? null
                : () => cubit.decline(inv.id, userId),
          ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No se pudieron cargar tus invitaciones.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
