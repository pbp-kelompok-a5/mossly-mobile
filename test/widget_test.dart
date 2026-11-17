import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mossly_mobile/app.dart';
import 'package:mossly_mobile/core/session.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('lima tab modul tampil dan bisa berpindah', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final session = Session();
    await session.signIn('test-token');
    await tester.pumpWidget(MosslyApp(session: session));

    // cek jumlah 5 widget
    expect(find.byType(NavigationDestination), findsNWidgets(5));
    expect(find.text('Personal Sustainability Dashboard'), findsOneWidget);

    // klik ikon community
    await tester.tap(find.byIcon(Icons.forum_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Sustainability Community'), findsOneWidget);
  });
}
