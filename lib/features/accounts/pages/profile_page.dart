import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api_client.dart';
import '../../../core/session.dart';
import '../../../core/theme.dart';
import '../services/auth_service.dart';
import '../models/account_user.dart';
import '../widgets/auth_error.dart';
import '../widgets/auth_layout.dart';
import '../widgets/auth_theme.dart';

/// Profil akun aktif dan logout; pengaturan onboarding menyusul.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<AccountUser>? _profile;
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profile ??= _fetchProfile();
  }

  Future<AccountUser> _fetchProfile() async {
    final session = context.read<Session>();
    final token = session.token;
    try {
      return await AuthService(context.read<ApiClient>()).getProfile();
    } on ApiException catch (error) {
      // Jangan menghapus sesi yang lebih baru karena respons request lama.
      if (error.statusCode == 401 && session.token == token) {
        await session.signOut();
      }
      rethrow;
    }
  }

  void _reloadProfile() {
    setState(() {
      _profile = _fetchProfile();
    });
  }

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
          _error = authErrorMessage(error, action: AuthAction.logout);
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
              const SizedBox(height: MosslySpace.s4),
              FutureBuilder<AccountUser>(
                future: _profile,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.all(MosslySpace.s4),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthError(
                          message: authErrorMessage(
                            snapshot.error!,
                            action: AuthAction.profile,
                          ),
                        ),
                        TextButton(
                          onPressed: _loading ? null : _reloadProfile,
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    );
                  }
                  final user = snapshot.data;
                  if (user == null) {
                    return const Text('Data akun belum tersedia.');
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.displayName, style: text.titleLarge),
                      const SizedBox(height: MosslySpace.s2),
                      Text('@${user.username}'),
                      const SizedBox(height: MosslySpace.s2),
                      Text(
                        user.email.isEmpty ? 'Email belum diisi.' : user.email,
                      ),
                      if (user.age != null) ...[
                        const SizedBox(height: MosslySpace.s2),
                        Text('Umur: ${user.age} tahun'),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: MosslySpace.s4),
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
