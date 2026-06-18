import 'package:flutter/material.dart';

/// Placeholder for the Devices tab — wired to real data in a later pass.
class DevicesPlaceholder extends StatelessWidget {
  const DevicesPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Devices')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sensors_outlined, size: 56, color: Colors.grey),
            SizedBox(height: 12),
            Text('Dispositivos — próximamente'),
          ],
        ),
      ),
    );
  }
}
