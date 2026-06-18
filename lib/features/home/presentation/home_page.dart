import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cocina360/shared/presentation/session/auth/auth_cubit.dart';
import 'package:cocina360/shared/presentation/session/profile/profile_cubit.dart';
import 'package:cocina360/shared/presentation/session/profile/profile_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cocina360'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => context.read<AuthCubit>().logout(),
          ),
        ],
      ),
      body: Center(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            switch (state) {
              case NoProfile():
                return const Text("vas a caer");

              case ProfileLoading():
                return const CircularProgressIndicator();

              case ProfileLoaded(:final profile):
                return Text(
                  profile.fullName,
                  style: Theme.of(context).textTheme.headlineMedium,
                );

              case ProfileError(:final message):
                return Text(message);
            }
          },
        ),
      ),
    );
  }
}
