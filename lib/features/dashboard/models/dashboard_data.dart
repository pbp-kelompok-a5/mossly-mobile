class DashboardSummary {
  const DashboardSummary({
    required this.month,
    required this.emissionKg,
    required this.targetKg,
    required this.streakNow,
    required this.streakBest,
    required this.goalsDone,
    required this.goalsTotal,
    required this.communityActions,
    required this.badgesEarned,
    required this.badgesTotal,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final streak = json['streak'] as Map<String, dynamic>;
    final goals = json['goals'] as Map<String, dynamic>;
    final badges = json['badges'] as Map<String, dynamic>;
    return DashboardSummary(
      month: json['month'] as String,
      emissionKg: (json['emission_kg'] as num).toDouble(),
      targetKg: (json['target_kg'] as num?)?.toDouble(),
      streakNow: streak['now'] as int,
      streakBest: streak['best'] as int,
      goalsDone: goals['done'] as int,
      goalsTotal: goals['total'] as int,
      communityActions: json['community_actions'] as int,
      badgesEarned: badges['earned'] as int,
      badgesTotal: badges['total'] as int,
    );
  }

  final String month;
  final double emissionKg;
  final double? targetKg;
  final int streakNow;
  final int streakBest;
  final int goalsDone;
  final int goalsTotal;
  final int communityActions;
  final int badgesEarned;
  final int badgesTotal;
}

class DashboardBadge {
  const DashboardBadge({
    required this.code,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.categoryLabel,
    required this.earned,
    required this.earnedAt,
    required this.percent,
    required this.progress,
    required this.threshold,
  });

  factory DashboardBadge.fromJson(Map<String, dynamic> json) {
    return DashboardBadge(
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      category: json['category'] as String,
      categoryLabel: json['category_label'] as String,
      earned: json['earned'] as bool,
      earnedAt: json['earned_at'] as String?,
      percent: json['percent'] as int,
      progress: json['progress'] as String,
      threshold: json['threshold'] as int,
    );
  }

  final String code;
  final String name;
  final String description;
  final String icon;
  final String category;
  final String categoryLabel;
  final bool earned;
  final String? earnedAt;
  final int percent;
  final String progress;
  final int threshold;
}

class BadgeOverview {
  const BadgeOverview({
    required this.earned,
    required this.total,
    required this.badges,
  });

  factory BadgeOverview.fromJson(Map<String, dynamic> json) {
    final list = json['badges'] as List;
    return BadgeOverview(
      earned: json['earned'] as int,
      total: json['total'] as int,
      badges: list
          .whereType<Map<String, dynamic>>()
          .map(DashboardBadge.fromJson)
          .toList(),
    );
  }

  final int earned;
  final int total;
  final List<DashboardBadge> badges;
}