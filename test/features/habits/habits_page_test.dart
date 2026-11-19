import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mossly_mobile/core/api_client.dart';
import 'package:mossly_mobile/core/session.dart';
import 'package:mossly_mobile/core/theme.dart';
import 'package:mossly_mobile/features/habits/pages/habits_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _habitsJson =
    '{"date":"2026-10-26","scheduled_today":2,"done_today":1,"habits":['
    '{"id":1,"name":"Bawa tumbler","icon":"cup-soda","tint":"moss-100",'
    '"time_of_day":"pagi","frequency_type":"daily","weekdays":null,'
    '"start_date":"2026-08-27","is_scheduled_today":true,"is_done_today":true,'
    '"current_streak":3,"longest_streak":5,"next_milestone":7},'
    '{"id":2,"name":"Pilah sampah","icon":"recycle","tint":"clay-100",'
    '"time_of_day":"malam","frequency_type":"weekdays","weekdays":[0,2,4],'
    '"start_date":"2026-09-01","is_scheduled_today":true,"is_done_today":false,'
    '"current_streak":0,"longest_streak":2,"next_milestone":3}]}';

const _goalsJson =
    '[{"id":1,"title":"Naik transportasi umum 20 kali",'
    '"category":"transportasi","target_value":20.0,"unit":"kali",'
    '"start_date":"2026-10-01","deadline":"2026-10-30","status":"active",'
    '"progress":12.0,"percent":60,"days_left":4,"is_near_deadline":true,'
    '"completed_at":null,"checklist":['
    '{"id":1,"label":"Cek jadwal KRL","is_done":true},'
    '{"id":2,"label":"Isi saldo","is_done":false}]}]';

const _emptyHabitsJson =
    '{"date":"2026-10-26","scheduled_today":0,"done_today":0,"habits":[]}';

Future<void> _pumpPage(
  WidgetTester tester,
  Future<http.Response> Function(http.Request) handler,
) async {
  SharedPreferences.setMockInitialValues({});
  final session = Session();
  await session.signIn('test-token');
  final client = MockClient(handler);
  addTearDown(client.close);
  await tester.pumpWidget(
    Provider<ApiClient>.value(
      value: ApiClient(session, httpClient: client),
      child: MaterialApp(theme: buildMosslyTheme(), home: const HabitsPage()),
    ),
  );
}

void main() {
  testWidgets('menampilkan ringkasan hari ini, habit, dan goal', (
    tester,
  ) async {
    await _pumpPage(tester, (request) async {
      if (request.url.path.endsWith('/goals/')) {
        return http.Response(_goalsJson, 200);
      }
      return http.Response(_habitsJson, 200);
    });

    // Sebelum Future selesai: indikator memuat.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.text('1 dari 2 habit selesai'), findsOneWidget);
    expect(find.text('Bawa tumbler'), findsOneWidget);
    expect(find.text('Pilah sampah'), findsOneWidget);
    expect(find.text('Malam · Sen, Rab, Jum'), findsOneWidget);
    expect(find.text('Streak 3 hari'), findsOneWidget);

    await tester.tap(find.text('Goal'));
    await tester.pumpAndSettle();

    expect(find.text('Naik transportasi umum 20 kali'), findsOneWidget);
    expect(find.text('Goal kamu, semangat ya!'), findsOneWidget);
    expect(find.text('12 / 20 kali'), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
    expect(find.text('4 hari lagi'), findsOneWidget);
    expect(find.text('Checklist 1/2'), findsOneWidget);
  });

  testWidgets('keadaan kosong ditampilkan bila belum ada data', (tester) async {
    await _pumpPage(tester, (request) async {
      if (request.url.path.endsWith('/goals/')) {
        return http.Response('[]', 200);
      }
      return http.Response(_emptyHabitsJson, 200);
    });
    await tester.pumpAndSettle();

    expect(find.text('Belum ada habit'), findsOneWidget);

    await tester.tap(find.text('Goal'));
    await tester.pumpAndSettle();

    expect(find.text('Belum ada goal'), findsOneWidget);
  });

  testWidgets('gagal memuat menampilkan pesan dan Coba lagi berhasil', (
    tester,
  ) async {
    var habitCalls = 0;
    await _pumpPage(tester, (request) async {
      if (request.url.path.endsWith('/goals/')) {
        return http.Response('[]', 200);
      }
      habitCalls++;
      // Request pertama gagal, request berikutnya berhasil.
      return habitCalls == 1
          ? http.Response('{}', 500)
          : http.Response(_habitsJson, 200);
    });
    await tester.pumpAndSettle();

    expect(find.text('Data belum bisa dimuat'), findsOneWidget);
    expect(find.textContaining('Server sedang bermasalah'), findsOneWidget);

    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();

    expect(habitCalls, 2);
    expect(find.text('Bawa tumbler'), findsOneWidget);
  });

  testWidgets('tarik ke bawah memuat ulang data habit', (tester) async {
    var habitCalls = 0;
    await _pumpPage(tester, (request) async {
      if (request.url.path.endsWith('/goals/')) {
        return http.Response('[]', 200);
      }
      habitCalls++;
      return http.Response(_habitsJson, 200);
    });
    await tester.pumpAndSettle();
    expect(habitCalls, 1);

    await tester.fling(find.text('Bawa tumbler'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(habitCalls, 2);
  });

  testWidgets('di IndexedStack, data baru dimuat saat tab Habit dibuka', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final session = Session();
    await session.signIn('test-token');
    final paths = <String>[];
    final client = MockClient((request) async {
      paths.add(request.url.path);
      return request.url.path.endsWith('/goals/')
          ? http.Response('[]', 200)
          : http.Response(_habitsJson, 200);
    });
    addTearDown(client.close);

    Widget shell(int index) => Provider<ApiClient>.value(
      value: ApiClient(session, httpClient: client),
      child: MaterialApp(
        theme: buildMosslyTheme(),
        home: IndexedStack(
          index: index,
          children: const [Text('Tab lain'), HabitsPage()],
        ),
      ),
    );

    await tester.pumpWidget(shell(0));
    await tester.pumpAndSettle();
    expect(paths, isEmpty);

    await tester.pumpWidget(shell(1));
    await tester.pumpAndSettle();
    expect(paths, [endsWith('/habits/')]);
    expect(find.text('Bawa tumbler'), findsOneWidget);

    // Tab Goal baru memuat saat dibuka, lalu data tetap ada saat kembali.
    await tester.tap(find.text('Goal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Habit'));
    await tester.pumpAndSettle();
    expect(paths, [endsWith('/habits/'), endsWith('/goals/')]);
  });
}
