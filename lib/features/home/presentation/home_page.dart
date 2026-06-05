import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcompro/shared/presentation/session/profile/profile_cubit.dart';
import 'package:tcompro/shared/presentation/session/profile/profile_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            switch (state) {
              case NoProfile():
                return const SizedBox.shrink();

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
