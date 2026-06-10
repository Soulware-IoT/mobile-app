import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcompro/features/auth/presentation/pages/login/login_page.dart';
import 'package:tcompro/features/home/presentation/home_page.dart';
import 'package:tcompro/shared/presentation/session/auth/auth_state.dart';
import 'package:tcompro/shared/presentation/session/auth/auth_cubit.dart';
import 'package:tcompro/shared/presentation/session/profile/profile_cubit.dart';

class SessionGuard extends StatelessWidget {
  const SessionGuard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        switch (state) {
          case Authenticated(:final userId) || OfflineAuthenticated(:final userId):
            context.read<ProfileCubit>().loadProfile(userId);
            break;

          case NotAuthenticated():
            context.read<ProfileCubit>().clear();
            break;

          default:
            break;
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return switch (state) {
            AuthInitial() => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            AuthLoading() => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            Authenticated() || OfflineAuthenticated() => const HomePage(),
            NotAuthenticated() => const LoginPage(),
            AuthError(:final message) => Scaffold(
              body: Center(child: Text(message)),
            ),
          };
        },
      ),
    );
  }
}
