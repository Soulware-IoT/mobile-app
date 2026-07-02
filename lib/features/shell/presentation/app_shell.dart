import 'package:flutter/material.dart';
import 'package:cocina360/features/devices/presentation/pages/devices_page.dart';
import 'package:cocina360/features/organization/presentation/pages/organization_page.dart';
import 'package:cocina360/features/processes/presentation/pages/processes_page.dart';

/// Authenticated home: a bottom-nav shell over the Organization, Processes and
/// Devices tabs. Pages are kept alive via [IndexedStack].
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _pages = [
    OrganizationPage(),
    ProcessesPage(),
    DevicesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.apartment_outlined),
            selectedIcon: Icon(Icons.apartment),
            label: 'Organization',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_tree_outlined),
            selectedIcon: Icon(Icons.account_tree),
            label: 'Processes',
          ),
          NavigationDestination(
            icon: Icon(Icons.sensors_outlined),
            selectedIcon: Icon(Icons.sensors),
            label: 'Devices',
          ),
        ],
      ),
    );
  }
}
