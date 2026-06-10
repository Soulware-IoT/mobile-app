import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tcompro/shared/data/repositories/auth_repository_impl.dart';
import 'package:tcompro/shared/data/repositories/profile_repository_impl.dart';
import 'package:tcompro/shared/data/services/auth_local_service.dart';
import 'package:tcompro/shared/data/services/auth_remote_service.dart';
import 'package:tcompro/shared/data/services/profile_local_service.dart';
import 'package:tcompro/shared/data/services/profile_service.dart';
import 'package:tcompro/shared/domain/repositories/auth_repository.dart';
import 'package:tcompro/shared/domain/repositories/profile_repository.dart';
import 'package:tcompro/shared/infrastructure/local/dao/profile_dao.dart';
import 'package:tcompro/shared/infrastructure/local/database.dart';
import 'package:tcompro/shared/infrastructure/network/network_checker.dart';
import 'package:tcompro/shared/infrastructure/remote/supabase.dart';
import 'package:tcompro/shared/presentation/session/auth/auth_cubit.dart';
import 'package:tcompro/shared/presentation/session/profile/profile_cubit.dart';

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
        child: child,
      ),
    );
  }
}
