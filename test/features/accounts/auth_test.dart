import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mossly_mobile/app.dart';
import 'package:mossly_mobile/core/api_client.dart';
import 'package:mossly_mobile/core/session.dart';
import 'package:mossly_mobile/features/accounts/models/login_result.dart';
import 'package:mossly_mobile/features/accounts/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Respons tanpa token yang valid ditolak', () {
    for (final token in [null, '', '   ', 42]) {
      expect(
        () => LoginResult.fromJson({'token': token}),
        throwsFormatException,
      );
    }
  });

  test(
    'Login memakai kontrak JSON dan mempertahankan spasi password',
    () async {
      final session = Session();
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/auth/login/');
        expect(request.headers['Content-Type'], 'application/json');
        expect(request.headers.containsKey('Authorization'), isFalse);
        expect(jsonDecode(request.body), {
          'username': 'sheva',
          'password': ' password ',
        });
        return http.Response(
          jsonEncode({'token': 'test-token', 'user': {}}),
          200,
        );
      });
      addTearDown(client.close);
      final result = await AuthService(ApiClient(session, httpClient: client))
          .login(' sheva ', ' password ');
      expect(result.token, 'test-token');
    },
  );

  test('Error jaringan menjadi pesan yang dapat dicoba ulang', () async {
    final client = MockClient(
      (_) async => throw http.ClientException('offline'),
    );
    addTearDown(client.close);
    final service = AuthService(ApiClient(Session(), httpClient: client));
    await expectLater(
      service.login('sheva', 'password'),
      throwsA(isA<AuthException>()),
    );
  });

  test(
    'Logout mengirim token; 401 dianggap token sudah tidak berlaku',
    () async {
      final session = Session();
      await session.signIn('expired-test-token');
      final client = MockClient((request) async {
        expect(request.url.path, '/api/v1/auth/logout/');
        expect(request.method, 'POST');
        expect(request.headers['Authorization'], 'Token expired-test-token');
        return http.Response('{"detail":"Invalid token."}', 401);
      });
      addTearDown(client.close);
      await AuthService(ApiClient(session, httpClient: client)).logout();
    },
  );

  Future<void> mountApp(
    WidgetTester tester,
    Session session,
    Future<http.Response> Function(http.Request) handler,
  ) async {
    final client = MockClient(handler);
    addTearDown(client.close);
    await tester.pumpWidget(
      MosslyApp(
        session: session,
        apiClient: ApiClient(session, httpClient: client),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> fillLogin(WidgetTester tester) async {
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Username'),
      'sheva',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Kata sandi'),
      'password',
    );
    await tester.ensureVisible(find.text('Masuk'));
    await tester.tap(find.text('Masuk'));
  }

  testWidgets('Belum login hanya melihat form; input kosong tidak dikirim', (
    tester,
  ) async {
    var requests = 0;
    await mountApp(tester, Session(), (_) async {
      requests++;
      return http.Response('{}', 500);
    });
    expect(find.byType(NavigationBar), findsNothing);
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    expect(find.text('Username wajib diisi.'), findsOneWidget);
    expect(find.text('Kata sandi wajib diisi.'), findsOneWidget);
    expect(requests, 0);
  });

  testWidgets(
    'Login menyimpan token, pulih setelah dibuka ulang, logout mencabut sesi',
    (tester) async {
      final session = Session();
      var logoutRequests = 0;
      await mountApp(tester, session, (request) async {
        if (request.url.path.endsWith('/login/')) {
          return http.Response(
            '{"token":"test-token","user":{"username":"sheva"}}',
            200,
          );
        }
        expect(request.url.path, '/api/v1/auth/logout/');
        expect(request.headers['Authorization'], 'Token test-token');
        logoutRequests++;
        return http.Response('', 204);
      });
      await fillLogin(tester);
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Masuk'), findsNothing);
      expect(
        (await SharedPreferences.getInstance()).getString('auth_token'),
        'test-token',
      );
      final restored = Session();
      await restored.load();
      expect(restored.isLoggedIn, isTrue);
      expect(restored.token, 'test-token');

      await tester.tap(find.byIcon(Icons.person_outline).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keluar'));
      await tester.pumpAndSettle();
      expect(logoutRequests, 1);
      expect(session.isLoggedIn, isFalse);
      expect(
        (await SharedPreferences.getInstance()).containsKey('auth_token'),
        isFalse,
      );
      expect(find.text('Masuk'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Login gagal menampilkan error DRF dan dapat dicoba lagi', (
    tester,
  ) async {
    var attempts = 0;
    await mountApp(tester, Session(), (_) async {
      attempts++;
      return attempts == 1
          ? http.Response('{"non_field_errors":["Kredensial salah."]}', 400)
          : http.Response('{"token":"test-token","user":{}}', 200);
    });
    await fillLogin(tester);
    await tester.pumpAndSettle();
    expect(find.text('Kredensial salah.'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(attempts, 2);
  });

  testWidgets('Respons login rusak tidak membuat sesi', (tester) async {
    final session = Session();
    await mountApp(
      tester,
      session,
      (_) async => http.Response('{"token":""}', 200),
    );
    await fillLogin(tester);
    await tester.pumpAndSettle();
    expect(session.isLoggedIn, isFalse);
    expect(
      find.text('Respons masuk tidak valid. Silakan coba lagi.'),
      findsOneWidget,
    );
  });

  testWidgets('Loading mencegah pengiriman login berulang', (tester) async {
    final pending = Completer<http.Response>();
    var requests = 0;
    await mountApp(tester, Session(), (_) {
      requests++;
      return pending.future;
    });
    await fillLogin(tester);
    await tester.pump();
    expect(find.text('Sedang masuk...'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    pending.complete(http.Response('{"detail":"Gagal"}', 400));
    await tester.pumpAndSettle();
    expect(requests, 1);
  });

  for (final status in [500, 401, 404]) {
    testWidgets('Logout HTTP $status menangani sesi dengan benar', (
      tester,
    ) async {
      final session = Session();
      await session.signIn('test-token');
      await mountApp(
        tester,
        session,
        (_) async => http.Response('{"detail":"Gagal"}', status),
      );
      await tester.tap(find.byIcon(Icons.person_outline).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keluar'));
      await tester.pumpAndSettle();
      expect(session.isLoggedIn, status != 401);
      if (status != 401) {
        expect(
          find.text(
            status == 404
                ? 'Layanan keluar belum tersedia. Silakan coba lagi nanti.'
                : 'Server sedang bermasalah. Silakan coba lagi nanti.',
          ),
          findsOneWidget,
        );
        expect(
          (await SharedPreferences.getInstance()).getString('auth_token'),
          'test-token',
        );
        expect(
          tester.widget<FilledButton>(find.byType(FilledButton).last).onPressed,
          isNotNull,
        );
      } else {
        expect(find.text('Masuk'), findsOneWidget);
      }
    });
  }

  testWidgets('Form tetap dapat digunakan di layar kecil dengan keyboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await mountApp(tester, Session(), (_) async => http.Response('{}', 400));
    await tester.ensureVisible(find.text('Masuk'));
    expect(tester.takeException(), isNull);
  });
}
