import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cocina360/features/auth/presentation/pages/login/login_page.dart';
import 'package:cocina360/features/auth/presentation/pages/register/register_page.dart';
import 'package:cocina360/features/devices/domain/model/iot_device.dart';
import 'package:cocina360/features/devices/domain/repositories/device_repository.dart';
import 'package:cocina360/features/devices/presentation/cubit/device_detail_cubit.dart';
import 'package:cocina360/features/devices/presentation/pages/device_detail_page.dart';
import 'package:cocina360/features/organization/domain/model/organization.dart';
import 'package:cocina360/features/organization/domain/model/organization_member.dart';
import 'package:cocina360/features/organization/domain/repositories/organization_repository.dart';
import 'package:cocina360/features/organization/presentation/cubit/create_organization_cubit.dart';
import 'package:cocina360/features/organization/presentation/cubit/delete_organization_cubit.dart';
import 'package:cocina360/features/organization/presentation/cubit/edit_member_permissions_cubit.dart';
import 'package:cocina360/features/organization/presentation/cubit/edit_organization_cubit.dart';
import 'package:cocina360/features/organization/presentation/cubit/my_invitations_cubit.dart';
import 'package:cocina360/features/organization/presentation/cubit/remove_member_cubit.dart';
import 'package:cocina360/features/organization/presentation/pages/create_organization_page.dart';
import 'package:cocina360/features/organization/presentation/pages/edit_member_permissions_page.dart';
import 'package:cocina360/features/organization/presentation/pages/edit_organization_page.dart';
import 'package:cocina360/features/organization/presentation/pages/member_detail_page.dart';
import 'package:cocina360/features/organization/presentation/pages/my_invitations_page.dart';
import 'package:cocina360/features/processes/domain/model/control_format.dart';
import 'package:cocina360/features/processes/domain/repositories/internal_control_repository.dart';
import 'package:cocina360/features/processes/presentation/cubit/new_registry_cubit.dart';
import 'package:cocina360/features/processes/presentation/pages/new_registry_page.dart';
import 'package:cocina360/features/shell/presentation/app_shell.dart';
import 'package:cocina360/shared/presentation/session/auth/auth_cubit.dart';
import 'package:cocina360/shared/presentation/session/auth/auth_state.dart';

part 'app_routes.dart';

GoRouter createRouter(BuildContext context) {
  final authCubit = context.read<AuthCubit>();

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: _AuthStateListenable(authCubit),
    redirect: (context, state) {
      final authState = authCubit.state;
      final onAuth =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      if (authState is AuthInitial) return null;

      final authenticated =
          authState is Authenticated || authState is OfflineAuthenticated;

      if (!authenticated && !onAuth) return AppRoutes.login;
      if (authenticated && onAuth) return AppRoutes.home;

      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.home, builder: (_, _) => const AppShell()),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginPage()),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, _) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.createOrganization,
        builder: (context, state) => BlocProvider(
          create: (ctx) =>
              CreateOrganizationCubit(ctx.read<OrganizationRepository>()),
          child: const CreateOrganizationPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.editOrganization,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (ctx) =>
                  EditOrganizationCubit(ctx.read<OrganizationRepository>()),
            ),
            BlocProvider(
              create: (ctx) =>
                  DeleteOrganizationCubit(ctx.read<OrganizationRepository>()),
            ),
          ],
          child: EditOrganizationPage(
            organization: state.extra as Organization,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.memberDetail,
        builder: (context, state) => BlocProvider(
          create: (ctx) =>
              RemoveMemberCubit(ctx.read<OrganizationRepository>()),
          child: MemberDetailPage(member: state.extra as OrganizationMember),
        ),
      ),
      GoRoute(
        path: AppRoutes.editMemberPermissions,
        builder: (context, state) => BlocProvider(
          create: (ctx) =>
              EditMemberPermissionsCubit(ctx.read<OrganizationRepository>()),
          child: EditMemberPermissionsPage(
            member: state.extra as OrganizationMember,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.myInvitations,
        builder: (context, state) => BlocProvider(
          create: (ctx) =>
              MyInvitationsCubit(ctx.read<OrganizationRepository>()),
          child: const MyInvitationsPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.deviceDetail,
        builder: (context, state) => BlocProvider(
          create: (ctx) => DeviceDetailCubit(ctx.read<DeviceRepository>()),
          child: DeviceDetailPage(device: state.extra as IotDevice),
        ),
      ),
      GoRoute(
        path: AppRoutes.newRegistry,
        builder: (context, state) => BlocProvider(
          create: (ctx) =>
              NewRegistryCubit(ctx.read<InternalControlRepository>()),
          child: NewRegistryPage(format: state.extra as ControlFormat),
        ),
      ),
    ],
  );
}

/// Bridges [AuthCubit] state changes into GoRouter's [Listenable] refresh
/// mechanism so the router re-evaluates the redirect on every auth transition.
class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(AuthCubit cubit) {
    cubit.stream.listen((_) => notifyListeners());
  }
}
