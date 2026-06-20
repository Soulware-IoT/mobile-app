import 'package:flutter/material.dart';
import 'package:cocina360/l10n/app_localizations.dart';

/// Placeholder for the Processes tab — wired to real data in a later pass.
class ProcessesPlaceholder extends StatelessWidget {
  const ProcessesPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.processesTitle)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.account_tree_outlined,
              size: 56,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(l10n.processesComingSoon),
          ],
        ),
      ),
    );
  }
}
