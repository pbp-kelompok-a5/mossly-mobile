import 'package:flutter/material.dart';
import '../../../core/widgets/module_placeholder.dart';

/// Halaman utama modul Sustainability Community
class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Komunitas')),
      body: const ModulePlaceholder(
        icon: Icons.forum_outlined,
        title: 'Sustainability Community',
        owner: 'Isybal Sama Eleazar Malau',
        description: 'Berbagi tips dan pencapaian, balas, dan beri like.',
      ),
    );
  }
}
