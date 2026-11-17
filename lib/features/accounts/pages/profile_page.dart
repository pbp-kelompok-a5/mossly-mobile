import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api_client.dart';
import '../../../core/session.dart';
import '../../../core/theme.dart';
import '../services/auth_service.dart';
import '../widgets/auth_error.dart';
import '../widgets/auth_layout.dart';
import '../widgets/auth_theme.dart';

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
    return MosslyAuthTheme(child: Builder(builder: _buildPage));
  }

  Widget _buildPage(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SafeArea(
        child: AuthLayout(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.all(MosslySpace.s3),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(MosslySpace.radiusMd),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: scheme.onPrimaryContainer,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: MosslySpace.s6),
              Text('Kamu sudah masuk', style: text.headlineSmall),
              const SizedBox(height: MosslySpace.s2),
              Text(
                'Keluar dari akun setelah selesai menggunakan Mossly.',
                style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
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
                          color: scheme.onSurfaceVariant,
                        ),
                      )
                    : const Icon(Icons.logout, size: 20),
                label: Text(_loading ? 'Sedang keluar...' : 'Keluar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
