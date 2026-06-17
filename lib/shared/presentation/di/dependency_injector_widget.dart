import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cocina360/shared/data/repositories/auth_repository_impl.dart';
import 'package:cocina360/shared/data/repositories/profile_repository_impl.dart';
import 'package:cocina360/shared/data/services/auth_local_service.dart';
import 'package:cocina360/shared/data/services/auth_remote_service.dart';
import 'package:cocina360/shared/data/services/profile_local_service.dart';
import 'package:cocina360/shared/data/services/profile_service.dart';
import 'package:cocina360/shared/domain/repositories/auth_repository.dart';
import 'package:cocina360/shared/domain/repositories/profile_repository.dart';
import 'package:cocina360/shared/infrastructure/local/dao/profile_dao.dart';
import 'package:cocina360/shared/infrastructure/local/database.dart';
import 'package:cocina360/shared/infrastructure/network/network_checker.dart';
import 'package:cocina360/shared/infrastructure/remote/supabase.dart';
import 'package:cocina360/shared/presentation/session/auth/auth_cubit.dart';
import 'package:cocina360/shared/presentation/session/auth/auth_state.dart';
import 'package:cocina360/shared/presentation/session/profile/profile_cubit.dart';

class DependencyInjectorWidget extends StatelessWidget {
  final Widget child;
  final String supabaseUrl;
  final FlutterSecureStorage secureStorage;
  final AppDatabase database;

  const DependencyInjectorWidget({
    super.key,
    required this.child,
    required this.supabaseUrl,
    required this.secureStorage,
    required this.database,
  });

  @override
  Widget build(BuildContext context) {
    final connectionChecker = NetworkChecker(supabaseUrl);

    final authLocalService = AuthLocalService(secureStorage);
    final authRemoteService = AuthRemoteService(supabase);

    final profileRemoteService = ProfileService(supabase);
    final profileLocalService = ProfileLocalService(ProfileDao(database));

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(
            authRemoteService,
            authLocalService,
            connectionChecker,
          ),
        ),
        RepositoryProvider<ProfileRepository>(
          create: (_) => ProfileRepositoryImpl(
            profileRemoteService,
            profileLocalService,
            connectionChecker,
          ),
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
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            switch (state) {
              case Authenticated(:final userId) ||
                  OfflineAuthenticated(:final userId):
                context.read<ProfileCubit>().loadProfile(userId);
              case NotAuthenticated():
                context.read<ProfileCubit>().clear();
              default:
                break;
            }
          },
          child: child,
        ),
      ),
    );
  }
}
