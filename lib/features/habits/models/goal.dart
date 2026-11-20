/// Status goal
enum GoalStatus {
  active('Aktif'),
  completed('Selesai'),
  expired('Lewat deadline');

  const GoalStatus(this.label);

  final String label;

  static GoalStatus fromJson(Object? value) => switch (value) {
    'completed' => GoalStatus.completed,
    'expired' => GoalStatus.expired,
    _ => GoalStatus.active,
  };
}

/// Satu item checklist dalam suatu goal
class GoalChecklistItem {
  const GoalChecklistItem({
    required this.id,
    required this.label,
    required this.isDone,
  });

  final int id;
  final String label;
  final bool isDone;

  factory GoalChecklistItem.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final label = json['label'];
    if (id is! int || label is! String) {
      throw const FormatException('Data checklist goal tidak valid.');
    }
    return GoalChecklistItem(
      id: id,
      label: label,
      isDone: json['is_done'] as bool? ?? false,
    );
  }
}

/// Satu goal dari GET /api/v1/goals/ (balasan berupa list)
/// Progres, persen, status, dan sisa hari dihitung di server
class Goal {
  const Goal({
    required this.id,
    required this.title,
    required this.category,
    required this.targetValue,
    required this.unit,
    required this.startDate,
    required this.deadline,
    required this.status,
    required this.progress,
    required this.percent,
    required this.daysLeft,
    required this.isNearDeadline,
    required this.completedAt,
    required this.checklist,
  });

  final int id;
  final String title;

  /// transportasi, emisi, plastik, sampah, atau komunitas
  final String category;
  final double targetValue;

  /// kali, hari, atau kg_co2e
  final String unit;

  final DateTime startDate;
  final DateTime deadline;
  final GoalStatus status;
  final double progress;

  /// 0–100, dibulatkan ke bawah oleh server
  final int percent;

  /// Negatif bila deadline sudah lewat, 0 di hari deadline
  final int daysLeft;
  final bool isNearDeadline;
  final DateTime? completedAt;
  final List<GoalChecklistItem> checklist;

  factory Goal.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    final target = json['target_value'];
    final deadline = json['deadline'];
    final checklist = json['checklist'];
    final completedAt = json['completed_at'];
    if (id is! int ||
        title is! String ||
        target is! num ||
        deadline is! String) {
      throw const FormatException('Data goal tidak valid.');
    }
    return Goal(
      id: id,
      title: title,
      category: json['category'] as String? ?? '',
      targetValue: target.toDouble(),
      unit: json['unit'] as String? ?? 'kali',
      startDate: DateTime.parse(json['start_date'] as String),
      deadline: DateTime.parse(deadline),
      status: GoalStatus.fromJson(json['status']),
      progress: (json['progress'] as num? ?? 0).toDouble(),
      percent: json['percent'] as int? ?? 0,
      daysLeft: json['days_left'] as int? ?? 0,
      isNearDeadline: json['is_near_deadline'] as bool? ?? false,
      completedAt: completedAt is String ? DateTime.parse(completedAt) : null,
      checklist: checklist is List
          ? checklist
                .whereType<Map<String, dynamic>>()
                .map(GoalChecklistItem.fromJson)
                .toList()
          : const [],
    );
  }

  String get categoryLabel => switch (category) {
    'transportasi' => 'Transportasi',
    'emisi' => 'Emisi',
    'plastik' => 'Plastik',
    'sampah' => 'Sampah',
    'komunitas' => 'Komunitas',
    _ => category,
  };

  String get unitLabel => unit == 'kg_co2e' ? 'kg CO2e' : unit;

  /// Nilai 0.0–1.0 untuk LinearProgressIndicator
  double get progressFraction => (percent.clamp(0, 100)) / 100;

  int get checklistDone => checklist.where((item) => item.isDone).length;
}

/// Menampilkan angka tanpa ".0" bila bulat, misalnya 12.0 → "12"
String formatGoalNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}
