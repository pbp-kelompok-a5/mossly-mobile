import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api_client.dart';
import '../../../core/session.dart';
import '../../../core/theme.dart';
import '../services/auth_service.dart';
import '../widgets/auth_error.dart';

/// Halaman utama modul Login & Onboarding. Profil lengkap menyusul.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _loading = false;
  String? _error;

  Future<void> _logout() async {
    if (_loading) {
      return;
    }
    final service = AuthService(context.read<ApiClient>());
    final session = context.read<Session>();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await service.logout();
      await session.signOut();
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = authErrorMessage(error, loggingIn: false);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(MosslySpace.s6),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.person_outline, size: 56, color: scheme.primary),
                const SizedBox(height: MosslySpace.s4),
                Text(
                  'Kamu sudah masuk',
                  style: text.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: MosslySpace.s2),
                const Text(
                  'Keluar dari akun setelah selesai menggunakan Mossly.',
                  textAlign: TextAlign.center,
                ),
                if (_error != null) ...[
                  const SizedBox(height: MosslySpace.s4),
                  AuthError(message: _error!),
                ],
                const SizedBox(height: MosslySpace.s6),
                FilledButton.icon(
                  onPressed: _loading ? null : _logout,
                  icon: _loading
                      ? SizedBox(
                          width: MosslySpace.s4,
                          height: MosslySpace.s4,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: scheme.primary,
                          ),
                        )
                      : const Icon(Icons.logout),
                  label: Text(_loading ? 'Sedang keluar...' : 'Keluar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
