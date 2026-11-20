import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mossly_mobile/core/api_client.dart';
import 'package:mossly_mobile/core/session.dart';
import 'package:mossly_mobile/features/habits/services/habit_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Session session;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    session = Session();
    await session.signIn('test-token');
  });

  HabitService serviceWith(MockClientHandler handler) {
    final client = MockClient(handler);
    addTearDown(client.close);
    return HabitService(ApiClient(session, httpClient: client));
  }

  test('fetchHabits memanggil /habits/ dengan token', () async {
    late http.Request sent;
    final service = serviceWith((request) async {
      sent = request;
      return http.Response(
        '{"date":"2026-10-26","scheduled_today":0,"done_today":0,"habits":[]}',
        200,
      );
    });

    final overview = await service.fetchHabits();

    expect(sent.method, 'GET');
    expect(sent.url.path, endsWith('/api/v1/habits/'));
    expect(sent.headers['Authorization'], 'Token test-token');
    expect(overview.habits, isEmpty);
  });

  test('fetchGoals memanggil /goals/ dan membaca list', () async {
    late http.Request sent;
    final service = serviceWith((request) async {
      sent = request;
      return http.Response(
        '[{"id":1,"title":"Naik KRL","category":"transportasi",'
        '"target_value":20.0,"unit":"kali","start_date":"2026-10-01",'
        '"deadline":"2026-10-30","status":"active","progress":12.0,'
        '"percent":60,"days_left":4,"is_near_deadline":true,'
        '"completed_at":null,"checklist":[]}]',
        200,
      );
    });

    final goals = await service.fetchGoals();

    expect(sent.url.path, endsWith('/api/v1/goals/'));
    expect(goals.single.title, 'Naik KRL');
    expect(goals.single.percent, 60);
  });

  test('error server menjadi pesan yang dapat ditampilkan', () async {
    final service = serviceWith((_) async => http.Response('{}', 500));

    expect(
      service.fetchHabits(),
      throwsA(
        isA<HabitServiceException>().having(
          (e) => e.message,
          'message',
          contains('Server sedang bermasalah'),
        ),
      ),
    );
  });

  test('bentuk JSON yang salah tidak membuat aplikasi crash', () async {
    final service = serviceWith((_) async => http.Response('{"id":1}', 200));

    expect(service.fetchGoals(), throwsA(isA<HabitServiceException>()));
    expect(service.fetchHabits(), throwsA(isA<HabitServiceException>()));
  });

  test('gagal koneksi menjadi pesan coba lagi', () async {
    final service = serviceWith((_) async => throw http.ClientException('x'));

    expect(
      service.fetchGoals(),
      throwsA(
        isA<HabitServiceException>().having(
          (e) => e.message,
          'message',
          contains('Tidak dapat terhubung'),
        ),
      ),
    );
  });
}
