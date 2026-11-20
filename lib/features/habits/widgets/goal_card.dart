import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../models/goal.dart';

/// Kartu satu goal: judul, kategori, status, progress bar, deadline, checklist
class GoalCard extends StatelessWidget {
  const GoalCard({super.key, required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final progressText =
        '${formatGoalNumber(goal.progress)} / '
        '${formatGoalNumber(goal.targetValue)} ${goal.unitLabel}';
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(MosslySpace.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(goal.title, style: text.titleMedium)),
                const SizedBox(width: MosslySpace.s2),
                _StatusChip(status: goal.status),
              ],
            ),
            const SizedBox(height: MosslySpace.s1),
            Text(
              goal.categoryLabel,
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: MosslySpace.s3),
            ClipRRect(
              borderRadius: BorderRadius.circular(MosslySpace.radiusSm),
              child: LinearProgressIndicator(
                value: goal.progressFraction,
                minHeight: MosslySpace.s2,
                backgroundColor: scheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: MosslySpace.s2),
            Row(
              children: [
                Expanded(child: Text(progressText, style: text.bodyMedium)),
                Text('${goal.percent}%', style: text.labelLarge),
              ],
            ),
            const SizedBox(height: MosslySpace.s2),
            _DeadlineText(goal: goal),
            if (goal.checklist.isNotEmpty) ...[
              const SizedBox(height: MosslySpace.s3),
              Text(
                'Checklist ${goal.checklistDone}/${goal.checklist.length}',
                style: text.labelLarge,
              ),
              const SizedBox(height: MosslySpace.s1),
              for (final item in goal.checklist)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: MosslySpace.s1),
                  child: Row(
                    children: [
                      Icon(
                        item.isDone
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        size: 20,
                        color: item.isDone ? scheme.primary : scheme.outline,
                      ),
                      const SizedBox(width: MosslySpace.s2),
                      Expanded(
                        child: Text(
                          item.label,
                          style: text.bodyMedium?.copyWith(
                            decoration: item.isDone
                                ? TextDecoration.lineThrough
                                : null,
                            color: item.isDone ? scheme.onSurfaceVariant : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final GoalStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground) = switch (status) {
      GoalStatus.completed => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
      ),
      GoalStatus.expired => (scheme.errorContainer, scheme.error),
      GoalStatus.active => (scheme.surfaceContainerHigh, scheme.onSurface),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MosslySpace.s2,
        vertical: MosslySpace.s1,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(MosslySpace.radiusSm),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: foreground),
      ),
    );
  }
}

class _DeadlineText extends StatelessWidget {
  const _DeadlineText({required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final days = goal.daysLeft;
    final String label;
    if (goal.status == GoalStatus.completed) {
      label = 'Goal tercapai';
    } else if (days > 0) {
      label = '$days hari lagi';
    } else if (days == 0) {
      label = 'Deadline hari ini';
    } else {
      label = 'Lewat ${-days} hari';
    }
    final warn = goal.isNearDeadline || goal.status == GoalStatus.expired;
    final color = warn ? scheme.secondary : scheme.onSurfaceVariant;
    return Row(
      children: [
        Icon(
          warn ? Icons.schedule : Icons.event_outlined,
          size: 16,
          color: color,
        ),
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
