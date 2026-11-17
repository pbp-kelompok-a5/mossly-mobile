import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mossly_mobile/app.dart';
import 'package:mossly_mobile/core/api_client.dart';
import 'package:mossly_mobile/core/session.dart';
import 'package:mossly_mobile/features/accounts/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const user = {
  'id': 7,
  'username': 'baru',
  'email': 'baru@example.test',
  'display_name': 'Nama Baru',
  'umur': 18,
};

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> mount(
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

  Future<void> openRegister(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Belum punya akun? Daftar'));
    await tester.tap(find.text('Belum punya akun? Daftar'));
    await tester.pumpAndSettle();
  }

  Future<void> enter(WidgetTester tester, String label, String value) async {
    final field = find.widgetWithText(TextFormField, label);
    await tester.ensureVisible(field);
    await tester.enterText(field, value);
    await tester.pumpAndSettle();
  }

  Future<void> fill(WidgetTester tester) async {
    await enter(tester, 'Username', 'baru');
    await enter(tester, 'Email', 'baru@example.test');
    await enter(tester, 'Nama tampilan', 'Nama Baru');
    await enter(tester, 'Umur', '18');
    await enter(tester, 'Kata sandi', 'Rimbun!Lembah-7284');
    await enter(tester, 'Konfirmasi kata sandi', 'Rimbun!Lembah-7284');
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.pumpAndSettle();
    final button = find.widgetWithText(FilledButton, 'Buat akun');
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  testWidgets('Daftar membuat sesi, memuat profil sendiri, lalu dapat logout', (
    tester,
  ) async {
    final session = Session();
    var registrations = 0;
    await mount(tester, session, (request) async {
      if (request.url.path.endsWith('/register/')) {
        registrations++;
        expect(request.method, 'POST');
        expect(jsonDecode(request.body), {
          'username': 'baru',
          'email': 'baru@example.test',
          'display_name': 'Nama Baru',
          'umur': 18,
          'password1': 'Rimbun!Lembah-7284',
          'password2': 'Rimbun!Lembah-7284',
        });
        expect(request.headers.containsKey('Authorization'), isFalse);
        return http.Response(
          jsonEncode({'token': 'new-token', 'user': user}),
          201,
        );
      }
      expect(request.headers['Authorization'], 'Token new-token');
      if (request.method == 'GET') {
        expect(request.url.path, '/api/v1/auth/me/');
        return http.Response(jsonEncode(user), 200);
      }
      expect(request.url.path, '/api/v1/auth/logout/');
      return http.Response('', 204);
    });
    await openRegister(tester);
    await fill(tester);
    await submit(tester);
    expect(registrations, 1);
    expect(session.token, 'new-token');
    expect(
      (await SharedPreferences.getInstance()).getString('auth_token'),
      'new-token',
    );
    expect(find.text('Daftar akun'), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.tap(find.byIcon(Icons.person_outline).last);
    await tester.pumpAndSettle();
    expect(find.text('Nama Baru'), findsOneWidget);
    expect(find.text('@baru'), findsOneWidget);
    expect(find.text('baru@example.test'), findsOneWidget);
    expect(find.text('new-token'), findsNothing);
    await tester.ensureVisible(find.text('Keluar'));
    await tester.tap(find.text('Keluar'));
    await tester.pumpAndSettle();
    expect(session.token, isNull);
    expect(find.text('Masuk'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('Form kosong, umur kurang, dan konfirmasi salah tidak dikirim', (
    tester,
  ) async {
    var requests = 0;
    await mount(tester, Session(), (_) async {
      requests++;
      return http.Response('{}', 400);
    });
    await openRegister(tester);
    await submit(tester);
    expect(requests, 0);
    expect(find.text('Umur minimal 18 tahun.'), findsOneWidget);
    await fill(tester);
    await enter(tester, 'Umur', '17');
    await enter(tester, 'Konfirmasi kata sandi', 'tidak-sama');
    await submit(tester);
    expect(requests, 0);
    expect(find.text('Konfirmasi kata sandi harus sama.'), findsOneWidget);
  });

  testWidgets(
    'Error email/username dari Django ditampilkan dan dapat dicoba lagi',
    (tester) async {
      final session = Session();
      await mount(
        tester,
        session,
        (_) async => http.Response(
          '{"email":["Email ini sudah digunakan."],"username":["Username sudah digunakan."]}',
          400,
        ),
      );
      await openRegister(tester);
      await fill(tester);
      await submit(tester);
      expect(find.textContaining('Email ini sudah digunakan.'), findsOneWidget);
      expect(find.textContaining('Username sudah digunakan.'), findsOneWidget);
      expect(session.isLoggedIn, isFalse);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );
    },
  );

  testWidgets('Respons register tanpa token tidak membuat sesi', (
    tester,
  ) async {
    final session = Session();
    await mount(
      tester,
      session,
      (_) async => http.Response('{"token":""}', 201),
    );
    await openRegister(tester);
    await fill(tester);
    await submit(tester);
    expect(session.isLoggedIn, isFalse);
    expect(
      find.text('Respons pendaftaran tidak valid. Silakan coba lagi.'),
      findsOneWidget,
    );
  });

  testWidgets('Kembali dari daftar menuju form login', (tester) async {
    await mount(tester, Session(), (_) async => http.Response('{}', 400));
    await openRegister(tester);
    await tester.ensureVisible(find.text('Sudah punya akun? Masuk'));
    await tester.tap(find.text('Sudah punya akun? Masuk'));
    await tester.pumpAndSettle();
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Daftar akun'), findsNothing);
  });

  testWidgets('Profil gagal dapat dimuat ulang tanpa mengubah sesi', (
    tester,
  ) async {
    final session = Session();
    await session.signIn('profile-token');
    var attempts = 0;
    await mount(tester, session, (request) async {
      expect(request.headers['Authorization'], 'Token profile-token');
      attempts++;
      return attempts == 1
          ? http.Response('{}', 500)
          : http.Response(jsonEncode(user), 200);
    });
    await tester.tap(find.byIcon(Icons.person_outline).last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Coba lagi'));
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.text('Nama Baru'), findsOneWidget);
    expect(attempts, 2);
    expect(session.isLoggedIn, isTrue);
  });

  testWidgets('Token tersimpan yang ditolak server kembali ke login', (
    tester,
  ) async {
    final session = Session();
    await session.signIn('expired-token');
    await mount(
      tester,
      session,
      (_) async => http.Response('{"detail":"Invalid token."}', 401),
    );
    expect(session.isLoggedIn, isFalse);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(
      (await SharedPreferences.getInstance()).containsKey('auth_token'),
      isFalse,
    );
  });

  testWidgets('Profil memuat respons secara asinkron', (tester) async {
    final session = Session();
    await session.signIn('profile-token');
    final pending = Completer<http.Response>();
    final client = MockClient((_) => pending.future);
    addTearDown(client.close);
    await tester.pumpWidget(
      MosslyApp(
        session: session,
        apiClient: ApiClient(session, httpClient: client),
      ),
    );
    await tester.pump();
    await tester.tap(find.byIcon(Icons.person_outline).last);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.complete(http.Response(jsonEncode(user), 200));
    await tester.pumpAndSettle();
    expect(find.text('Nama Baru'), findsOneWidget);
  });

  test('Service register mempertahankan spasi password', () async {
    final client = MockClient((request) async {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['password1'], ' password ');
      expect(body['password2'], ' password ');
      return http.Response('{"token":"new-token"}', 201);
    });
    addTearDown(client.close);
    await AuthService(ApiClient(Session(), httpClient: client)).register(
      username: 'baru',
      email: 'baru@example.test',
      displayName: 'Nama Baru',
      age: 18,
      password: ' password ',
      passwordConfirmation: ' password ',
    );
  });

  testWidgets(
    'Form daftar tetap bisa di-scroll di ponsel kecil dengan keyboard',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = const FakeViewPadding(bottom: 260);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      await mount(tester, Session(), (_) async => http.Response('{}', 400));
      await openRegister(tester);
      await fill(tester);
      await submit(tester);
      expect(tester.takeException(), isNull);
    },
  );
}
