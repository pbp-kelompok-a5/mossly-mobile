import 'package:flutter/material.dart';

import '../../../core/widgets/module_placeholder.dart';

/// Halaman utama modul Sustainable Habit & Goal Tracker
class HabitsPage extends StatelessWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Habit & Goal')),
      body: const ModulePlaceholder(
        icon: Icons.eco_outlined,
        title: 'Sustainable Habit & Goal Tracker',
        owner: 'Tania Ju',
        description: 'Check-in kebiasaan harian dan pantau progres goal.',
      ),
    );
  }
}
