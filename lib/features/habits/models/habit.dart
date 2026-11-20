/// Satu habit dari GET /api/v1/habits/ (field `habits[]`)
///
/// Status hari ini dan streak dihitung di server (services.py Django)
class Habit {
  const Habit({
    required this.id,
    required this.name,
    required this.icon,
    required this.tint,
    required this.timeOfDay,
    required this.frequencyType,
    required this.weekdays,
    required this.startDate,
    required this.isScheduledToday,
    required this.isDoneToday,
    required this.currentStreak,
    required this.longestStreak,
    required this.nextMilestone,
  });

  final int id;
  final String name;

  /// Nama ikon Lucide dari web
  final String icon;

  /// Nama warna primitif dari web
  final String tint;

  /// pagi, siang, malam, atau kapan_saja
  final String timeOfDay;

  /// daily atau weekdays
  final String frequencyType;

  /// Nomor hari (Senin = 0) untuk habit "weekdays", null untuk "daily"
  final List<int>? weekdays;

  final DateTime startDate;
  final bool isScheduledToday;
  final bool isDoneToday;
  final int currentStreak;
  final int longestStreak;

  /// Milestone streak berikutnya, null bila semua milestone sudah tercapai
  final int? nextMilestone;

  factory Habit.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final weekdays = json['weekdays'];
    final nextMilestone = json['next_milestone'];
    if (id is! int || name is! String) {
      throw const FormatException('Data habit tidak valid.');
    }
    if (weekdays != null && weekdays is! List) {
      throw const FormatException('Data hari habit tidak valid.');
    }
    if (nextMilestone != null && nextMilestone is! int) {
      throw const FormatException('Data milestone habit tidak valid.');
    }
    return Habit(
      id: id,
      name: name,
      icon: json['icon'] as String? ?? 'leaf',
      tint: json['tint'] as String? ?? 'moss-100',
      timeOfDay: json['time_of_day'] as String? ?? 'kapan_saja',
      frequencyType: json['frequency_type'] as String? ?? 'daily',
      weekdays: (weekdays as List?)?.whereType<int>().toList(),
      startDate: DateTime.parse(json['start_date'] as String),
      isScheduledToday: json['is_scheduled_today'] as bool? ?? false,
      isDoneToday: json['is_done_today'] as bool? ?? false,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      nextMilestone: nextMilestone as int?,
    );
  }

  /// Label waktu bahasa indonesia
  String get timeOfDayLabel => switch (timeOfDay) {
    'pagi' => 'Pagi',
    'siang' => 'Siang',
    'malam' => 'Malam',
    _ => 'Kapan saja',
  };

  /// "Setiap hari" atau daftar hari
  String get scheduleLabel {
    final days = weekdays;
    if (frequencyType != 'weekdays' || days == null || days.isEmpty) {
      return 'Setiap hari';
    }
    const names = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return days.where((d) => d >= 0 && d < 7).map((d) => names[d]).join(', ');
  }
}

/// Seluruh balasan GET /api/v1/habits/: ringkasan hari ini + daftar habit
class HabitOverview {
  const HabitOverview({
    required this.date,
    required this.scheduledToday,
    required this.doneToday,
    required this.habits,
  });

  /// Tanggal "hari ini" menurut server (zona waktu lokal Django)
  final DateTime date;
  final int scheduledToday;
  final int doneToday;
  final List<Habit> habits;

  factory HabitOverview.fromJson(Map<String, dynamic> json) {
    final date = json['date'];
    final habits = json['habits'];
    if (date is! String || habits is! List) {
      throw const FormatException('Data daftar habit tidak valid.');
    }
    return HabitOverview(
      date: DateTime.parse(date),
      scheduledToday: json['scheduled_today'] as int? ?? 0,
      doneToday: json['done_today'] as int? ?? 0,
      habits: habits
          .whereType<Map<String, dynamic>>()
          .map(Habit.fromJson)
          .toList(),
    );
  }
}
