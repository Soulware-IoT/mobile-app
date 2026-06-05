import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tcompro/shared/domain/repositories/auth_repository.dart';
import 'package:tcompro/shared/presentation/session/auth/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;
  late final StreamSubscription<AuthState> _subscription;

  AuthCubit(this.repository) : super(const AuthInitial()) {
    _subscription = repository.authStateChanges.listen((state) {
      print('AUTH STATE => $state');
      emit(state);
    });
  }

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
