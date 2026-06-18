import 'package:flutter/material.dart';

/// Placeholder for the Processes tab — wired to real data in a later pass.
class ProcessesPlaceholder extends StatelessWidget {
  const ProcessesPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Processes')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_tree_outlined, size: 56, color: Colors.grey),
            SizedBox(height: 12),
            Text('Procesos — próximamente'),
          ],
        ),
      ),
    );
  }
}
