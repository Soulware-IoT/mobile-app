import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cocina360/features/auth/presentation/pages/login/login_page.dart';
import 'package:cocina360/features/auth/presentation/pages/register/register_page.dart';
import 'package:cocina360/features/home/presentation/home_page.dart';
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
      GoRoute(path: AppRoutes.home, builder: (_, _) => const HomePage()),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginPage()),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, _) => const RegisterPage(),
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
