import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcompro/shared/domain/model/auth_session.dart';
import 'package:tcompro/shared/domain/repositories/auth_repository.dart';
import 'package:tcompro/shared/presentation/session/auth/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;
  late final StreamSubscription<AuthSession> _subscription;

  AuthCubit(this.repository) : super(const AuthInitial()) {
    _subscription = repository.authStateChanges.listen(
      (session) => emit(_toState(session)),
    );
    _bootstrap();
  }

  /// Resolves the initial session immediately so the UI doesn't hang on
  /// [AuthInitial] when the auth stream is slow or silent (e.g. cold start
  /// while offline).
  Future<void> _bootstrap() async {
    final session = await repository.currentSession();
    emit(_toState(session));
  }

  AuthState _toState(AuthSession session) => switch (session) {
    ActiveSession(:final userId) => Authenticated(userId),
    OfflineSession(:final userId) => OfflineAuthenticated(userId),
    NoSession() => const NotAuthenticated(),
  };

  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading());

    try {
      await repository.login(email: email, password: password);
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> googleLogin() async {
    emit(const AuthLoading());

    try {
      await repository.googleLogin();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());

    try {
      await repository.register(email: email, password: password);
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> googleRegister() async {
    emit(const AuthLoading());

    try {
      await repository.googleRegister();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      await repository.logout();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
