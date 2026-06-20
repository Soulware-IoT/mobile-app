import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cocina360/features/auth/presentation/pages/login/widgets/login_form_card.dart';
import 'package:cocina360/features/auth/presentation/pages/login/widgets/login_register_link.dart';
import 'package:cocina360/l10n/app_localizations.dart';
import 'package:cocina360/shared/presentation/router/app_router.dart';
import 'package:cocina360/shared/presentation/session/auth/auth_cubit.dart';
import 'package:cocina360/shared/presentation/session/auth/auth_state.dart';
import 'package:cocina360/shared/presentation/widgets/auth_brand_header.dart';
import 'package:cocina360/shared/presentation/widgets/auth_google_button.dart';
import 'package:cocina360/shared/presentation/widgets/oauth_divider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthCubit>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  Future<void> _googleLogin() async {
    await context.read<AuthCubit>().googleLogin();
  }

  void _goToRegister() => context.go(AppRoutes.register);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final loading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  AuthBrandHeader(
                    authCaption: AppLocalizations.of(context)!.loginCaption,
                  ),
                  const SizedBox(height: 48),
                  LoginFormCard(
                    formKey: _formKey,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    loading: loading,
                    onSubmit: _login,
                  ),
                  const SizedBox(height: 16),
                  const OAuthDivider(),
                  const SizedBox(height: 16),
                  AuthGoogleButton(loading: loading, onPressed: _googleLogin),
                  const SizedBox(height: 32),
                  LoginRegisterLink(
                    loading: loading,
                    onRegister: _goToRegister,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
