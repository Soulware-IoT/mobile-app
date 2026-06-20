import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cocina360/features/organization/domain/model/organization.dart';
import 'package:cocina360/features/organization/domain/model/organization_member.dart';
import 'package:cocina360/features/organization/presentation/cubit/invitations_cubit.dart';
import 'package:cocina360/features/organization/presentation/cubit/invitations_state.dart';
import 'package:cocina360/features/organization/presentation/cubit/my_organizations_cubit.dart';
import 'package:cocina360/features/organization/presentation/cubit/organization_cubit.dart';
import 'package:cocina360/features/organization/presentation/cubit/organization_state.dart';
import 'package:cocina360/features/organization/presentation/widgets/invitation_card.dart';
import 'package:cocina360/features/organization/presentation/widgets/invite_member_dialog.dart';
import 'package:cocina360/features/organization/presentation/widgets/member_card.dart';
import 'package:cocina360/features/organization/presentation/widgets/organization_header_card.dart';
import 'package:cocina360/features/organization/presentation/widgets/organization_location_card.dart';
import 'package:cocina360/features/shell/presentation/widgets/app_drawer.dart';
import 'package:cocina360/l10n/app_localizations.dart';
import 'package:cocina360/shared/presentation/error/localized_error.dart';
import 'package:cocina360/shared/presentation/router/app_router.dart';
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
      context.read<MyOrganizationsCubit>().load(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cocina360'),
        actions: [
          BlocBuilder<OrganizationCubit, OrganizationState>(
            builder: (context, state) {
              if (state is! OrganizationLoaded) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: l10n.editOrganizationTooltip,
                onPressed: () => context.push(
                  AppRoutes.editOrganization,
                  extra: state.organization,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            tooltip: l10n.myInvitationsTooltip,
            onPressed: () => context.push(AppRoutes.myInvitations),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: BlocListener<OrganizationCubit, OrganizationState>(
        listenWhen: (prev, curr) => curr is OrganizationLoaded,
        listener: (context, state) {
          if (state is OrganizationLoaded) {
            context.read<InvitationsCubit>().load(state.organization.id);
          }
        },
        child: BlocBuilder<OrganizationCubit, OrganizationState>(
        builder: (context, state) {
          return switch (state) {
            OrganizationInitial() ||
            OrganizationLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            OrganizationEmpty() => const _EmptyView(),
            OrganizationError(:final error) => _ErrorView(
              message: localizedError(context, error),
              onRetry: _load,
            ),
            OrganizationLoaded(:final organization, :final members) =>
              _OrganizationContent(organization: organization, members: members),
          };
        },
        ),
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
                AppLocalizations.of(context)!.membersManagementTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            FilledButton.icon(
              onPressed: () => showInviteMemberDialog(
                context,
                organizationId: organization.id,
              ),
              icon: const Icon(Icons.add, size: 18),
              label: Text(AppLocalizations.of(context)!.addMember),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (members.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(AppLocalizations.of(context)!.noMembers),
          )
        else
          ...members.map(
            (m) => MemberCard(
              member: m,
              onTap: () =>
                  context.push(AppRoutes.memberDetail, extra: m),
            ),
          ),
        const SizedBox(height: 28),
        const _PendingInvitations(),
      ],
    );
  }
}

/// Pending invitations section, backed by [InvitationsCubit] (loaded when the
/// organization loads).
class _PendingInvitations extends StatelessWidget {
  const _PendingInvitations();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvitationsCubit, InvitationsState>(
      builder: (context, state) {
        final pending = switch (state) {
          InvitationsLoaded(:final pending) => pending,
          _ => const [],
        };

        // Hide the section entirely while there's nothing pending to show
        // (initial/loading/empty/error all collapse to no section).
        if (state is! InvitationsLoaded || pending.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.pendingInvitations,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            ...pending.map((i) => InvitationCard(invitation: i)),
          ],
        );
      },
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.business_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.emptyOrganizations,
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
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              l10n.organizationLoadError,
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
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
