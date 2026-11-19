import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../models/habit.dart';

/// Kartu satu habit: nama, jadwal, streak, dan status hari ini
class HabitTile extends StatelessWidget {
  const HabitTile({super.key, required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final milestone = habit.nextMilestone;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(MosslySpace.s4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(habit.name, style: text.titleMedium),
                  const SizedBox(height: MosslySpace.s1),
                  Text(
                    '${habit.timeOfDayLabel} · ${habit.scheduleLabel}',
                    style: text.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: MosslySpace.s2),
                  Wrap(
                    spacing: MosslySpace.s3,
                    runSpacing: MosslySpace.s1,
                    children: [
                      _Stat(
                        icon: Icons.local_fire_department_outlined,
                        label: 'Streak ${habit.currentStreak} hari',
                      ),
                      _Stat(
                        icon: Icons.emoji_events_outlined,
                        label: 'Terbaik ${habit.longestStreak}',
                      ),
                      if (milestone != null)
                        _Stat(
                          icon: Icons.flag_outlined,
                          label: 'Target $milestone hari',
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: MosslySpace.s2),
            _TodayBadge(habit: habit),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: MosslySpace.s1),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _TodayBadge extends StatelessWidget {
  const _TodayBadge({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (!habit.isScheduledToday) {
      return Tooltip(
        message: 'Tidak dijadwalkan hari ini',
        child: Icon(Icons.event_busy_outlined, color: scheme.outline),
      );
    }
    if (habit.isDoneToday) {
      return Tooltip(
        message: 'Sudah check-in hari ini',
        child: Icon(Icons.check_circle, color: scheme.primary),
      );
    }
    return Tooltip(
      message: 'Belum check-in hari ini',
      child: Icon(Icons.radio_button_unchecked, color: scheme.outline),
    );
  }
}
