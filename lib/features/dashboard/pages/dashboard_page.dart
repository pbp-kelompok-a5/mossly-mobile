import 'package:flutter/material.dart';

import '../../../core/widgets/module_placeholder.dart';

/// Halaman utama modul Personal Sustainability Dashboard
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: const ModulePlaceholder(
        icon: Icons.dashboard_outlined,
        title: 'Personal Sustainability Dashboard',
        owner: 'Fildza Hasnalia Nabila',
        description: 'Ringkasan emisi, streak, goal, target bulanan, dan koleksi badge.',
      ),
    );
  }
}
