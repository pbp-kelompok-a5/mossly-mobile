import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/api_client.dart';
import '../../../core/session.dart';
import '../../../core/theme.dart';
import '../services/auth_service.dart';
import '../widgets/auth_error.dart';
import '../widgets/auth_layout.dart';
import '../widgets/auth_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_loading || !_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    final service = AuthService(context.read<ApiClient>());
    final session = context.read<Session>();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await service.login(_username.text, _password.text);
      if (!mounted) {
        return;
      }
      await session.signIn(result.token);
      TextInput.finishAutofillContext();
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = authErrorMessage(error, loggingIn: true);
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
      body: SafeArea(
        child: AuthLayout(
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'SELAMAT DATANG KEMBALI',
                    style: text.labelSmall?.copyWith(
                      color: scheme.primary,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: MosslySpace.s3),
                  Text('Masuk ke Mossly', style: text.headlineSmall),
                  const SizedBox(height: MosslySpace.s2),
                  Text(
                    'Masuk untuk melanjutkan langkah kecilmu.',
                    style: text.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: MosslySpace.s8),
                  TextFormField(
                    controller: _username,
                    enabled: !_loading,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      hintText: 'Masukkan username',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    autofillHints: const [AutofillHints.username],
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    textInputAction: TextInputAction.next,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Username wajib diisi.'
                        : null,
                  ),
                  const SizedBox(height: MosslySpace.s6),
                  TextFormField(
                    controller: _password,
                    enabled: !_loading,
                    obscureText: _obscurePassword,
                    autocorrect: false,
                    enableSuggestions: false,
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _login(),
                    decoration: InputDecoration(
                      labelText: 'Kata sandi',
                      hintText: 'Masukkan kata sandi',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? 'Tampilkan kata sandi'
                            : 'Sembunyikan kata sandi',
                        onPressed: _loading
                            ? null
                            : () => setState(() {
                                _obscurePassword = !_obscurePassword;
                              }),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Kata sandi wajib diisi.'
                        : null,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: MosslySpace.s4),
                    AuthError(message: _error!),
                  ],
                  const SizedBox(height: MosslySpace.s6),
                  FilledButton(
                    onPressed: _loading ? null : _login,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_loading) ...[
                          SizedBox(
                            width: MosslySpace.s4,
                            height: MosslySpace.s4,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: MosslySpace.s2),
                        ],
                        Flexible(
                          child: Text(_loading ? 'Sedang masuk...' : 'Masuk'),
                        ),
                        if (!_loading) ...[
                          const SizedBox(width: MosslySpace.s2),
                          const Icon(Icons.arrow_forward, size: 20),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
