import 'package:flutter/material.dart';
import 'package:cocina360/l10n/app_localizations.dart';
import 'package:cocina360/shared/presentation/theme/theme.dart';

class RegisterLoginLink extends StatelessWidget {
  final bool loading;
  final VoidCallback onLogin;

  const RegisterLoginLink({
    super.key,
    required this.loading,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.haveAccountQuestion,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: loading ? null : onLogin,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: AppTheme.seedColor,
          ),
          child: Text(
            l10n.loginLink,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.seedColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
