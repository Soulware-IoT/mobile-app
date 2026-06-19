import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cocina360/features/organization/domain/model/organization.dart';
import 'package:cocina360/features/organization/domain/model/organization_member.dart';
import 'package:cocina360/features/organization/presentation/cubit/organization_cubit.dart';
import 'package:cocina360/features/organization/presentation/cubit/organization_state.dart';
import 'package:cocina360/features/organization/presentation/widgets/member_card.dart';
import 'package:cocina360/features/organization/presentation/widgets/organization_header_card.dart';
import 'package:cocina360/features/organization/presentation/widgets/organization_location_card.dart';
import 'package:cocina360/features/shell/presentation/widgets/app_drawer.dart';
import 'package:cocina360/shared/presentation/session/auth/auth_cubit.dart';
import 'package:cocina360/shared/presentation/session/auth/auth_state.dart';

class OrganizationPage extends StatefulWidget {
  const OrganizationPage({super.key});

  @override
  State<OrganizationPage> createState() => _OrganizationPageState();
}

class _OrganizationPageState extends State<OrganizationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final userId = switch (context.read<AuthCubit>().state) {
      Authenticated(:final userId) => userId,
      OfflineAuthenticated(:final userId) => userId,
      _ => null,
    };
    if (userId != null) {
      context.read<OrganizationCubit>().load(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cocina360'),
        actions: [
          // Notifications are not implemented yet.
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: null),
        ],
      ),
      drawer: const AppDrawer(),
      body: BlocBuilder<OrganizationCubit, OrganizationState>(
        builder: (context, state) {
          return switch (state) {
            OrganizationInitial() ||
            OrganizationLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            OrganizationEmpty() => const _EmptyView(),
            OrganizationError(:final message) => _ErrorView(
              message: message,
              onRetry: _load,
            ),
            OrganizationLoaded(:final organization, :final members) =>
              _OrganizationContent(organization: organization, members: members),
          };
        },
      ),
    );
  }
}

class _OrganizationContent extends StatelessWidget {
  final Organization organization;
  final List<OrganizationMember> members;

  const _OrganizationContent({required this.organization, required this.members});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        OrganizationHeaderCard(organization: organization),
        const SizedBox(height: 16),
        OrganizationLocationCard(organization: organization),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: Text(
                'Members Management',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            // Inviting members is deferred to a later pass.
            FilledButton.icon(
              onPressed: null,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Member'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (members.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text('Aún no hay miembros en esta organización.'),
          )
        else
          ...members.map((m) => MemberCard(member: m)),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.business_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Todavía no perteneces a ninguna organización.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
              'No se pudo cargar la organización.',
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
