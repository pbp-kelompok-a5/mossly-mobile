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

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    for (final controller in [
      _username,
      _email,
      _name,
      _age,
      _password,
      _confirmation,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _register() async {
    if (_loading || !_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    final service = AuthService(context.read<ApiClient>());
    final session = context.read<Session>();
    final navigator = Navigator.of(context);
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await service.register(
        username: _username.text,
        email: _email.text,
        displayName: _name.text,
        age: int.parse(_age.text),
        password: _password.text,
        passwordConfirmation: _confirmation.text,
      );
      if (!mounted) {
        return;
      }
      await session.signIn(result.token);
      if (mounted) {
        TextInput.finishAutofillContext();
        // Gerbang sesi mengganti halaman root menjadi HomeShell. Tutup form
        // daftar agar tombol kembali tidak membuka form auth setelah berhasil.
        navigator.popUntil((route) => route.isFirst);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = authErrorMessage(error, action: AuthAction.register);
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

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Bagian ini wajib diisi.' : null;

  @override
  Widget build(BuildContext context) {
    return MosslyAuthTheme(child: Builder(builder: _buildPage));
  }

  Widget _buildPage(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar akun')),
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
                    'Buat akun Mossly',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: MosslySpace.s2),
                  Text(
                    'Mulai langkah kecilmu dengan satu akun untuk web dan mobile.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: MosslySpace.s6),
                  TextFormField(
                    controller: _username,
                    enabled: !_loading,
                    maxLength: 150,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      counterText: '',
                    ),
                    autofillHints: const [AutofillHints.newUsername],
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    validator: _required,
                  ),
                  const SizedBox(height: MosslySpace.s4),
                  TextFormField(
                    controller: _email,
                    enabled: !_loading,
                    maxLength: 254,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      counterText: '',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        value != null &&
                            RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                .hasMatch(value.trim())
                        ? null
                        : 'Masukkan email yang valid.',
                  ),
                  const SizedBox(height: MosslySpace.s4),
                  TextFormField(
                    controller: _name,
                    enabled: !_loading,
                    maxLength: 80,
                    decoration: const InputDecoration(
                      labelText: 'Nama tampilan',
                      counterText: '',
                    ),
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.nickname],
                    textInputAction: TextInputAction.next,
                    validator: _required,
                  ),
                  const SizedBox(height: MosslySpace.s4),
                  TextFormField(
                    controller: _age,
                    enabled: !_loading,
                    decoration: const InputDecoration(
                      labelText: 'Umur',
                      helperText: 'Minimal 18 tahun.',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      final age = int.tryParse(value ?? '');
                      return age != null && age >= 18
                          ? null
                          : 'Umur minimal 18 tahun.';
                    },
                  ),
                  const SizedBox(height: MosslySpace.s4),
                  TextFormField(
                    controller: _password,
                    enabled: !_loading,
                    obscureText: _obscure,
                    autofillHints: const [AutofillHints.newPassword],
                    autocorrect: false,
                    enableSuggestions: false,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Kata sandi',
                      suffixIcon: IconButton(
                        tooltip: _obscure
                            ? 'Tampilkan kata sandi'
                            : 'Sembunyikan kata sandi',
                        onPressed: _loading
                            ? null
                            : () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (value) => value != null && value.length >= 8
                        ? null
                        : 'Kata sandi minimal 8 karakter.',
                  ),
                  const SizedBox(height: MosslySpace.s4),
                  TextFormField(
                    controller: _confirmation,
                    enabled: !_loading,
                    obscureText: _obscure,
                    autofillHints: const [AutofillHints.newPassword],
                    autocorrect: false,
                    enableSuggestions: false,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _register(),
                    decoration: const InputDecoration(
                      labelText: 'Konfirmasi kata sandi',
                    ),
                    validator: (value) =>
                        value != null &&
                            value.isNotEmpty &&
                            value == _password.text
                        ? null
                        : 'Konfirmasi kata sandi harus sama.',
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: MosslySpace.s4),
                    AuthError(message: _error!),
                  ],
                  const SizedBox(height: MosslySpace.s6),
                  FilledButton(
                    onPressed: _loading ? null : _register,
                    child: Text(_loading ? 'Membuat akun...' : 'Buat akun'),
                  ),
                  const SizedBox(height: MosslySpace.s3),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Sudah punya akun? Masuk'),
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
