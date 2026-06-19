import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cocina360/features/organization/data/repositories/organization_repository_impl.dart';
import 'package:cocina360/features/organization/data/services/organization_remote_service.dart';
import 'package:cocina360/features/organization/domain/repositories/organization_repository.dart';
import 'package:cocina360/features/organization/presentation/cubit/organization_cubit.dart';
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
import 'package:cocina360/shared/infrastructure/remote/api_gateway_client.dart';
import 'package:cocina360/shared/infrastructure/remote/session_claims.dart';
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

    // Organization data is read from the backend through the api-gw. The base
    // URL is empty until the gateway is provisioned; calls then fail fast and
    // the screen shows its error state (see api_gateway_client.dart).
    final apiGatewayClient = ApiGatewayClient(
      baseUrl: dotenv.env['API_GATEWAY_URL'] ?? '',
      supabase: supabase,
    );
    final organizationRemoteService = OrganizationRemoteService(apiGatewayClient);
    final sessionClaims = SessionClaims(supabase);

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
        RepositoryProvider<OrganizationRepository>(
          create: (_) => OrganizationRepositoryImpl(
            organizationRemoteService,
            sessionClaims,
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
          BlocProvider<OrganizationCubit>(
            create: (context) =>
                OrganizationCubit(context.read<OrganizationRepository>()),
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
