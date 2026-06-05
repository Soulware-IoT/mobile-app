import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcompro/shared/data/repositories/auth_repository_impl.dart';
import 'package:tcompro/shared/data/repositories/profile_repository_impl.dart';
import 'package:tcompro/shared/data/services/auth_service.dart';
import 'package:tcompro/shared/data/services/profile_service.dart';
import 'package:tcompro/shared/domain/repositories/auth_repository.dart';
import 'package:tcompro/shared/domain/repositories/profile_repository.dart';
import 'package:tcompro/shared/infrastructure/remote/supabase.dart';
import 'package:tcompro/shared/presentation/session/auth/auth_cubit.dart';
import 'package:tcompro/shared/presentation/session/profile/profile_cubit.dart';

class DependencyInjectorWidget extends StatelessWidget {
  final Widget child;

  const DependencyInjectorWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService(supabase);
    final profileService = ProfileService(supabase);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(authService),
        ),
        RepositoryProvider<ProfileRepository>(
          create: (_) => ProfileRepositoryImpl(profileService),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(context.read<AuthRepository>()),
          ),
          BlocProvider<ProfileCubit>(
            create: (context) =>
                ProfileCubit(context.read<ProfileRepository>()),
          ),
        ],
        child: child,
      ),
    );
  }
}
