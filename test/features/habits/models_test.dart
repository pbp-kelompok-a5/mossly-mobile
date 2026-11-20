import 'package:flutter_test/flutter_test.dart';
import 'package:mossly_mobile/features/habits/models/goal.dart';
import 'package:mossly_mobile/features/habits/models/habit.dart';

// Contoh JSON diambil dari kontrak di mossly/habits/tests_api.py (web).
void main() {
  group('HabitOverview.fromJson', () {
    test('membaca ringkasan hari ini dan daftar habit', () {
      final overview = HabitOverview.fromJson({
        'date': '2026-10-26',
        'scheduled_today': 1,
        'done_today': 1,
        'habits': [
          {
            'id': 3,
            'name': 'Bawa tumbler',
            'icon': 'cup-soda',
            'tint': 'moss-100',
            'time_of_day': 'pagi',
            'frequency_type': 'daily',
            'weekdays': null,
            'start_date': '2026-08-27',
            'is_scheduled_today': true,
            'is_done_today': true,
            'current_streak': 3,
            'longest_streak': 3,
            'next_milestone': 7,
          },
        ],
      });

      expect(overview.date, DateTime(2026, 10, 26));
      expect(overview.scheduledToday, 1);
      expect(overview.doneToday, 1);
      final habit = overview.habits.single;
      expect(habit.id, 3);
      expect(habit.name, 'Bawa tumbler');
      expect(habit.timeOfDayLabel, 'Pagi');
      expect(habit.scheduleLabel, 'Setiap hari');
      expect(habit.isDoneToday, isTrue);
      expect(habit.currentStreak, 3);
      expect(habit.nextMilestone, 7);
    });

    test('habit hari tertentu menampilkan nama hari', () {
      final habit = Habit.fromJson({
        'id': 1,
        'name': 'Pilah sampah',
        'frequency_type': 'weekdays',
        'weekdays': [0, 2, 4],
        'start_date': '2026-10-01',
        'next_milestone': null,
      });

      expect(habit.weekdays, [0, 2, 4]);
      expect(habit.scheduleLabel, 'Sen, Rab, Jum');
      expect(habit.nextMilestone, isNull);
    });

    test('JSON tanpa field wajib ditolak', () {
      expect(
        () => HabitOverview.fromJson({'detail': 'x'}),
        throwsFormatException,
      );
    });
  });

  group('Goal.fromJson', () {
    test('membaca progres, status, dan checklist', () {
      final goal = Goal.fromJson({
        'id': 5,
        'title': 'Naik transportasi umum 20 kali',
        'category': 'transportasi',
        'target_value': 20.0,
        'unit': 'kali',
        'start_date': '2026-10-01',
        'deadline': '2026-10-30',
        'status': 'active',
        'progress': 12.0,
        'percent': 60,
        'days_left': 4,
        'is_near_deadline': true,
        'completed_at': null,
        'checklist': [
          {'id': 1, 'label': 'Cek jadwal KRL', 'is_done': true},
          {'id': 2, 'label': 'Isi saldo', 'is_done': false},
        ],
      });

      expect(goal.categoryLabel, 'Transportasi');
      expect(goal.targetValue, 20);
      expect(goal.progress, 12);
      expect(goal.progressFraction, 0.6);
      expect(goal.status, GoalStatus.active);
      expect(goal.isNearDeadline, isTrue);
      expect(goal.checklist, hasLength(2));
      expect(goal.checklistDone, 1);
      expect(goal.completedAt, isNull);
    });

    test('goal selesai membaca completed_at dan satuan kg CO2e', () {
      final goal = Goal.fromJson({
        'id': 6,
        'title': 'Kurangi emisi',
        'category': 'emisi',
        'target_value': 10.5,
        'unit': 'kg_co2e',
        'start_date': '2026-10-01',
        'deadline': '2026-10-30',
        'status': 'completed',
        'progress': 10.5,
        'percent': 100,
        'days_left': 4,
        'is_near_deadline': false,
        'completed_at': '2026-10-26T12:00:00+07:00',
        'checklist': [],
      });

      expect(goal.status, GoalStatus.completed);
      expect(goal.unitLabel, 'kg CO2e');
      expect(goal.completedAt, DateTime.utc(2026, 10, 26, 5));
    });

    test('formatGoalNumber membuang .0 pada angka bulat', () {
      expect(formatGoalNumber(12.0), '12');
      expect(formatGoalNumber(2.25), '2.25');
      expect(formatGoalNumber(10.5), '10.5');
    });
  });
}
