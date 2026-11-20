import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mossly_mobile/core/api_client.dart';
import 'package:mossly_mobile/app.dart';
import 'package:mossly_mobile/core/session.dart';
import 'package:mossly_mobile/core/theme.dart';
import 'package:mossly_mobile/features/carbon/models/carbon_history.dart';
import 'package:mossly_mobile/features/carbon/pages/carbon_page.dart';
import 'package:mossly_mobile/features/carbon/services/carbon_service.dart';
import 'package:mossly_mobile/features/carbon/widgets/carbon_format.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> fixture(String name) => jsonDecode(
  File('test/features/carbon/fixtures/$name.json').readAsStringSync(),
) as Map<String, dynamic>;

http.Response response(Object data, [int status = 200]) => http.Response(
  jsonEncode(data),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final entry in {
      'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
      'PlusJakartaSans': 'assets/fonts/PlusJakartaSans-Variable.ttf',
      'RedHatDisplay': 'assets/fonts/RedHatDisplay-Variable.ttf',
    }.entries) {
      final loader = FontLoader(entry.key)
        ..addFont(rootBundle.load(entry.value));
      await loader.load();
    }
  });

  test(
    'model reads actual DRF numbers, Indonesian dates, and zero emission',
    () {
      final history = CarbonHistory.fromJson(fixture('history'));
      expect(history.trips, hasLength(3));
      expect(history.summary.totalTrips, 3);
      expect(history.summary.totalDistanceKm, closeTo(34.6, 0.0001));
      expect(history.summary.totalEmissionKg, closeTo(4.76, 0.0001));
      expect(history.trips.first.emissionKg, 0);
      expect(history.nextPage, isNull);
      expect(carbonDate(DateTime(2026, 11, 20)), '20 November 2026');
      expect(carbonNumber(1234.5), '1.234,5');
      expect(carbonEmission(0.0001), '<0,01');
      expect(carbonEmission(0), '0');
    },
  );

  test('malformed data cannot silently appear as zero emission', () {
    for (final invalid in ['4.2', null, -1, double.infinity]) {
      final history = fixture('history');
      (history['trips'] as List).first['distance_km'] = invalid;
      expect(() => CarbonHistory.fromJson(history), throwsFormatException);
    }
    final invalidDate = fixture('history');
    (invalidDate['trips'] as List).first['date'] = '2026-02-30';
    expect(() => CarbonHistory.fromJson(invalidDate), throwsFormatException);
  });

  test('incorrect pagination or duplicate records are rejected', () {
    final invalid = fixture('history');
    (invalid['pagination'] as Map)['next_page'] = 2;
    expect(() => CarbonHistory.fromJson(invalid), throwsFormatException);
    final duplicate = fixture('history');
    duplicate['trips'][1]['id'] = duplicate['trips'][0]['id'];
    expect(() => CarbonHistory.fromJson(duplicate), throwsFormatException);
  });

  test(
    'service uses shared token and exact CP1 routes and query parameters',
    () async {
      SharedPreferences.setMockInitialValues({});
      final session = Session();
      await session.signIn('test-token');
      final requests = <http.Request>[];
      final client = MockClient((request) async {
        requests.add(request);
        return response(
          fixture(request.url.path.endsWith('modes/') ? 'modes' : 'history'),
        );
      });
      addTearDown(client.close);
      final service = CarbonService(ApiClient(session, httpClient: client));
      await service.getModes();
      await service.getHistory(mode: 'sepeda', sort: 'distance');
      expect(requests.map((r) => r.url.path), [
        '/api/v1/carbon/modes/',
        '/api/v1/carbon/trips/',
      ]);
      expect(requests.last.headers['Authorization'], 'Token test-token');
      expect(requests.last.url.queryParameters, {
        'mode': 'sepeda',
        'sort': 'distance',
        'page': '1',
      });
    },
  );

  Future<void> mount(
    WidgetTester tester, {
    Future<http.Response> Function(http.Request)? handler,
    double width = 390,
    double textScale = 1,
    bool settle = true,
    GlobalKey? screenshotKey,
  }) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final session = Session();
    await session.signIn('test-token');
    final client = MockClient(
      handler ??
          (request) async => response(
            fixture(request.url.path.endsWith('modes/') ? 'modes' : 'history'),
          ),
    );
    addTearDown(client.close);
    await tester.pumpWidget(
      Provider<ApiClient>.value(
        value: ApiClient(session, httpClient: client),
        child: MaterialApp(
          theme: buildMosslyTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: RepaintBoundary(key: screenshotKey, child: const CarbonPage()),
        ),
      ),
    );
    if (settle) await tester.pumpAndSettle();
  }

  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      350,
      maxScrolls: 50,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('loading finishes with real history and numeric summary', (
    tester,
  ) async {
    final gate = Completer<http.Response>();
    await mount(
      tester,
      settle: false,
      handler: (request) async => request.url.path.endsWith('modes/')
          ? response(fixture('modes'))
          : gate.future,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    gate.complete(response(fixture('history')));
    await tester.pumpAndSettle();
    await scrollTo(tester, find.text('34,6'));
    expect(find.text('34,6'), findsOneWidget);
    expect(find.text('4,76'), findsOneWidget);
    await scrollTo(tester, find.text('Nol emisi langsung'));
    expect(find.text('Universitas Indonesia, Depok'), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.delete), findsNothing);
  });

  testWidgets('empty history is a valid state, with zero server summary', (
    tester,
  ) async {
    final empty = fixture('history')
      ..['trips'] = []
      ..['summary'] = {
        'total_trips': 0,
        'total_distance_km': 0,
        'total_co2e_kg': 0,
      };
    empty['pagination']['count'] = 0;
    await mount(
      tester,
      handler: (request) async => response(
        request.url.path.endsWith('modes/') ? fixture('modes') : empty,
      ),
    );
    await scrollTo(tester, find.text('Belum ada perjalanan'));
    expect(find.text('Belum ada perjalanan'), findsOneWidget);
    expect(find.text('Coba lagi'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed request can be retried', (tester) async {
    var calls = 0;
    await mount(
      tester,
      handler: (request) async {
        if (request.url.path.endsWith('modes/')) {
          return response(fixture('modes'));
        }
        return ++calls == 1
            ? response({'detail': 'Server unavailable'}, 503)
            : response(fixture('history'));
      },
    );
    await scrollTo(tester, find.text('Coba lagi'));
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    await scrollTo(tester, find.text('Riwayat perjalanan'));
    expect(calls, 2);
    expect(find.text('Riwayat belum dapat dimuat'), findsNothing);
  });

  testWidgets('401 explains the invalid session', (tester) async {
    await mount(
      tester,
      handler: (_) async => response({'detail': 'Invalid token'}, 401),
    );
    await scrollTo(tester, find.textContaining('Sesi tidak valid'));
    expect(find.textContaining('Silakan login kembali'), findsOneWidget);
  });

  testWidgets('broken JSON shows an error instead of invented data', (
    tester,
  ) async {
    await mount(
      tester,
      handler: (request) async => response(
        request.url.path.endsWith('modes/')
            ? fixture('modes')
            : {'trips': 'broken'},
      ),
    );
    await scrollTo(tester, find.textContaining('Data Carbon dari server'));
    expect(find.textContaining('Data Carbon dari server'), findsOneWidget);
    expect(find.text('0,0'), findsNothing);
  });

  testWidgets('filter and sort send new requests to the server', (
    tester,
  ) async {
    final queries = <Map<String, String>>[];
    await mount(
      tester,
      handler: (request) async {
        if (request.url.path.endsWith('modes/')) {
          return response(fixture('modes'));
        }
        queries.add(request.url.queryParameters);
        return response(fixture('history'));
      },
    );
    final chip = find.widgetWithText(ChoiceChip, 'Mobil');
    await scrollTo(tester, chip);
    await tester.tap(chip);
    await tester.pumpAndSettle();
    expect(queries.last, {'mode': 'mobil', 'sort': 'newest', 'page': '1'});
    await scrollTo(tester, find.byTooltip('Urutkan riwayat'));
    await tester.tap(find.byTooltip('Urutkan riwayat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jarak terjauh').last);
    await tester.pumpAndSettle();
    expect(queries.last, {'mode': 'mobil', 'sort': 'distance', 'page': '1'});
  });

  testWidgets('pull to refresh makes a fresh server request', (tester) async {
    var calls = 0;
    await mount(
      tester,
      handler: (request) async {
        if (request.url.path.endsWith('modes/')) {
          return response(fixture('modes'));
        }
        calls++;
        return response(fixture('history'));
      },
    );
    await tester.drag(find.byType(ListView), const Offset(0, 500));
    await tester.pumpAndSettle();
    expect(calls, greaterThan(1));
  });

  testWidgets('pagination keeps filters and new filters reset to page one', (
    tester,
  ) async {
    final queries = <Map<String, String>>[];
    await mount(
      tester,
      handler: (request) async {
        if (request.url.path.endsWith('modes/')) {
          return response(fixture('modes'));
        }
        queries.add(request.url.queryParameters);
        final page = int.parse(request.url.queryParameters['page']!);
        final data = fixture('history');
        final template = Map<String, dynamic>.from(data['trips'][0] as Map);
        data['trips'] = List.generate(
          page == 1 ? 20 : 1,
          (index) => {...template, 'id': (page - 1) * 20 + index + 1},
        );
        data['summary']['total_trips'] = 21;
        data['pagination'] = {
          'page': page,
          'pages': 2,
          'per_page': 20,
          'count': 21,
          'previous_page': page == 1 ? null : 1,
          'next_page': page == 1 ? 2 : null,
        };
        return response(data);
      },
    );
    await scrollTo(tester, find.text('Berikutnya'));
    await tester.tap(find.text('Berikutnya'));
    await tester.pumpAndSettle();
    expect(queries.last['page'], '2');
    await tester.drag(find.byType(ListView), const Offset(0, 10000));
    await tester.pumpAndSettle();
    final chip = find.widgetWithText(ChoiceChip, 'Mobil');
    await scrollTo(tester, chip);
    await tester.tap(chip);
    await tester.pumpAndSettle();
    expect(queries.last, {'mode': 'mobil', 'sort': 'newest', 'page': '1'});
  });

  testWidgets(
    'Carbon loads only when its tab opens and keeps other modules working',
    (tester) async {
      var carbonCalls = 0;
      SharedPreferences.setMockInitialValues({});
      final session = Session();
      await session.signIn('test-token');
      final client = MockClient((request) async {
        if (request.url.path.contains('/carbon/')) {
          carbonCalls++;
          return response(
            fixture(request.url.path.endsWith('modes/') ? 'modes' : 'history'),
          );
        }
        return response({
          'id': 1,
          'username': 'review',
          'email': 'review@example.test',
          'display_name': 'Review',
          'umur': 18,
        });
      });
      addTearDown(client.close);
      await tester.pumpWidget(
        MosslyApp(
          session: session,
          apiClient: ApiClient(session, httpClient: client),
        ),
      );
      await tester.pumpAndSettle();
      expect(carbonCalls, 0);
      await tester.tap(find.byIcon(Icons.route_outlined));
      await tester.pumpAndSettle();
      expect(carbonCalls, 2);
      expect(find.text('Setiap perjalanan punya jejak.'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.forum_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Sustainability Community'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('narrow screen and large text do not overflow', (tester) async {
    await mount(tester, width: 320, textScale: 1.6);
    await scrollTo(tester, find.text('Nol emisi langsung'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('capture Carbon mobile view for visual review', (tester) async {
    final key = GlobalKey();
    await mount(tester, screenshotKey: key);
    await tester.runAsync(() async {
      final outputDirectory = await Directory.systemTemp.createTemp(
        'mossly-carbon-preview-',
      );
      addTearDown(() => outputDirectory.delete(recursive: true));
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      File('${outputDirectory.path}/carbon-mobile-preview.png')
          .writeAsBytesSync(data!.buffer.asUint8List());
      image.dispose();
    });
  });
}
