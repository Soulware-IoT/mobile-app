import 'package:flutter/material.dart';
import 'package:cocina360/l10n/app_localizations.dart';
import 'package:cocina360/shared/presentation/theme/theme.dart';

class LoginRegisterLink extends StatelessWidget {
  final bool loading;
  final VoidCallback onRegister;

  const LoginRegisterLink({
    super.key,
    required this.loading,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.noAccountQuestion,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: loading ? null : onRegister,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: AppTheme.seedColor,
          ),
          child: Text(
            l10n.registerLink,
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
