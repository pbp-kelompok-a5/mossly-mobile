import 'package:flutter/material.dart';
import '../../../core/widgets/module_placeholder.dart';

/// Halaman utama modul Login & Onboarding
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: const ModulePlaceholder(
        icon: Icons.person_outline,
        title: 'Login & Onboarding',
        owner: 'Sheva Aquila Mahardika',
        description: 'Login, registrasi, onboarding, dan profil pengguna.',
      ),
    );
  }
}
