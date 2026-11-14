import 'package:flutter/material.dart';
import '../../../core/widgets/module_placeholder.dart';

/// Halaman utama modul Carbon Footprint Tracker
class CarbonPage extends StatelessWidget {
  const CarbonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Karbon')),
      body: const ModulePlaceholder(
        icon: Icons.route_outlined,
        title: 'Carbon Footprint Tracker',
        owner: 'Callysta Arviana',
        description: 'Catat perjalanan dan lihat estimasi emisi karbonnya.',
      ),
    );
  }
}
