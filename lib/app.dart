import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'core/session.dart';
import 'core/theme.dart';
import 'features/accounts/pages/login_page.dart';
import 'shell/home_shell.dart';

class MosslyApp extends StatelessWidget {
  const MosslyApp({super.key, required this.session, this.apiClient});

  final Session session;
  // Klien dapat diganti saat test agar tidak mengirim request ke server asli.
  final ApiClient? apiClient;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Session>.value(value: session),
        Provider<ApiClient>(create: (_) => apiClient ?? ApiClient(session)),
      ],
      child: MaterialApp(
        title: 'Mossly',
        debugShowCheckedModeBanner: false,
        theme: buildMosslyTheme(),
        home: Consumer<Session>(
          builder: (context, session, child) =>
              session.isLoggedIn ? const HomeShell() : const LoginPage(),
        ),
      ),
    );
  }
}
