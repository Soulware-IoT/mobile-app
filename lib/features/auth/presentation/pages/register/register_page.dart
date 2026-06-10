import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tcompro/features/auth/presentation/pages/register/widgets/register_form_card.dart';
import 'package:tcompro/shared/presentation/router/app_router.dart';
import 'package:tcompro/features/auth/presentation/pages/register/widgets/register_login_link.dart';
import 'package:tcompro/shared/presentation/session/auth/auth_cubit.dart';
import 'package:tcompro/shared/presentation/session/auth/auth_state.dart';
import 'package:tcompro/shared/presentation/widgets/auth_brand_header.dart';
import 'package:tcompro/shared/presentation/widgets/auth_google_button.dart';
import 'package:tcompro/shared/presentation/widgets/oauth_divider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthCubit>().register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  Future<void> _googleRegister() async {
    await context.read<AuthCubit>().googleRegister();
  }

  void _goToLogin() => context.go(AppRoutes.login);

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
                  const AuthBrandHeader(authCaption: 'Crea tu cuenta'),
                  const SizedBox(height: 48),
                  RegisterFormCard(
                    formKey: _formKey,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                    loading: loading,
                    onSubmit: _register,
                  ),
                  const SizedBox(height: 16),
                  const OAuthDivider(),
                  const SizedBox(height: 16),
                  AuthGoogleButton(
                    loading: loading,
                    onPressed: _googleRegister,
                  ),
                  const SizedBox(height: 32),
                  RegisterLoginLink(loading: loading, onLogin: _goToLogin),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
