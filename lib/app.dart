import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/api_client.dart';
import 'core/session.dart';
import 'core/theme.dart';
import 'shell/home_shell.dart';

class MosslyApp extends StatelessWidget {
  const MosslyApp({super.key, required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Session>.value(value: session),
        Provider<ApiClient>(create: (_) => ApiClient(session)),
      ],
      child: MaterialApp(
        title: 'Mossly',
        debugShowCheckedModeBanner: false,
        theme: buildMosslyTheme(),
        // placeholder menunggu modul Login & Onboarding
        // tampilkan halaman login kalau session.isLoggedIn masih false
        home: const HomeShell(),
      ),
    );
  }
}
