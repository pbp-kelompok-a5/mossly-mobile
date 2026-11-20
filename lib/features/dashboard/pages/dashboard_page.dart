import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../habits/widgets/async_states.dart';
import '../models/dashboard_data.dart';
import '../services/dashboard_service.dart';

/// Halaman utama modul Personal Sustainability Dashboard
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardData {
  const _DashboardData(this.summary, this.badges);

  final DashboardSummary summary;
  final BadgeOverview badges;
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<_DashboardData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_DashboardData> _load() async {
    final service = DashboardService.of(context);
    final results = await Future.wait<Object>([
      service.fetchSummary(),
      service.fetchBadges(),
    ]);
    return _DashboardData(
      results[0] as DashboardSummary,
      results[1] as BadgeOverview,
    );
  }

  void _retry() {
    setState(() => _future = _load());
  }

  Future<void> _refresh() async {
    final next = _load();
    setState(() => _future = next);
    try {
      await next;
    } catch (_) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<_DashboardData>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _DashboardContent(data: snapshot.data!);
            }
            if (snapshot.connectionState != ConnectionState.done) {
              return const LoadingState();
            }
            final error = snapshot.error;
            return ErrorState(
              message: error is DashboardServiceException
                  ? error.message
                  : 'Terjadi kesalahan yang tidak terduga.',
              onRetry: _retry,
            );
          },
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.data});

  final _DashboardData data;

  @override
  Widget build(BuildContext context) {
    final summary = data.summary;
    final text = Theme.of(context).textTheme;
    final isEmpty = summary.emissionKg == 0 &&
        summary.streakBest == 0 &&
        summary.goalsTotal == 0 &&
        summary.communityActions == 0 &&
        summary.badgesEarned == 0;
    if (isEmpty) {
      return const EmptyState(
        icon: Icons.eco_outlined,
        title: 'Belum ada aktivitas',
        message:
            'Mulai catat perjalanan, habit, atau goal. Ringkasan kamu akan muncul di sini.',
      );
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(MosslySpace.s4),
      children: [
        Text(_monthLabel(summary.month), style: text.titleLarge),
        const SizedBox(height: MosslySpace.s4),
        _EmissionCard(summary: summary),
        const SizedBox(height: MosslySpace.s4),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.local_fire_department_outlined,
                  label: 'Streak',
                  value: '${summary.streakNow} hari',
                  note: 'Terbaik ${summary.streakBest} hari',
                ),
              ),
              const SizedBox(width: MosslySpace.s4),
              Expanded(
                child: _StatCard(
                  icon: Icons.flag_outlined,
                  label: 'Goal',
                  value: '${summary.goalsDone}/${summary.goalsTotal}',
                  note: 'Goal selesai',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: MosslySpace.s4),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.groups_outlined,
                  label: 'Komunitas',
                  value: '${summary.communityActions}',
                  note: 'Aksi komunitas',
                ),
              ),
              const SizedBox(width: MosslySpace.s4),
              Expanded(
                child: _StatCard(
                  icon: Icons.emoji_events_outlined,
                  label: 'Badge',
                  value: '${summary.badgesEarned}/${summary.badgesTotal}',
                  note: 'Badge diraih',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: MosslySpace.s6),
        Text('Semua badge', style: text.titleMedium),
        const SizedBox(height: MosslySpace.s2),
        for (final badge in data.badges.badges) _BadgeTile(badge: badge),
      ],
    );
  }
}

class _EmissionCard extends StatelessWidget {
  const _EmissionCard({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final target = summary.targetKg;
    final hasTarget = target != null && target > 0;
    final over = hasTarget && summary.emissionKg > target;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(MosslySpace.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cloud_outlined, color: scheme.primary),
                const SizedBox(width: MosslySpace.s2),
                Text('Emisi bulan ini', style: text.labelLarge),
              ],
            ),
            const SizedBox(height: MosslySpace.s2),
            Text(
              '${summary.emissionKg.toStringAsFixed(1)} kg CO₂',
              style: text.headlineSmall,
            ),
            const SizedBox(height: MosslySpace.s2),
            if (hasTarget) ...[
              LinearProgressIndicator(
                value: (summary.emissionKg / target).clamp(0.0, 1.0).toDouble(),
                color: over ? scheme.error : null,
              ),
              const SizedBox(height: MosslySpace.s2),
              Text(
                over
                    ? 'Melebihi target ${target.toStringAsFixed(1)} kg'
                    : 'Target ${target.toStringAsFixed(1)} kg',
                style: text.bodySmall?.copyWith(
                  color: over ? scheme.error : scheme.onSurfaceVariant,
                ),
              ),
            ] else
              Text(
                'Target bulan ini belum diatur',
                style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.note,
  });

  final IconData icon;
  final String label;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(MosslySpace.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: scheme.primary),
                const SizedBox(width: MosslySpace.s2),
                Text(label, style: text.labelLarge),
              ],
            ),
            const SizedBox(height: MosslySpace.s2),
            Text(value, style: text.titleLarge),
            Text(
              note,
              style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});

  final DashboardBadge badge;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(MosslySpace.s4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              badge.earned ? Icons.emoji_events : Icons.lock_outline,
              color: badge.earned ? scheme.primary : scheme.onSurfaceVariant,
            ),
            const SizedBox(width: MosslySpace.s4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(badge.name, style: text.titleSmall),
                  Text(
                    badge.description,
                    style: text.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  if (!badge.earned) ...[
                    const SizedBox(height: MosslySpace.s2),
                    LinearProgressIndicator(
                      value: (badge.percent / 100).clamp(0.0, 1.0).toDouble(),
                    ),
                    const SizedBox(height: MosslySpace.s2),
                    Text(badge.progress, style: text.labelSmall),
                  ],
                ],
              ),
            ),
            if (badge.earned) Icon(Icons.check_circle, color: scheme.primary),
          ],
        ),
      ),
    );
  }
}

String _monthLabel(String month) {
  const names = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  final parts = month.split('-');
  final index = parts.length == 2 ? int.tryParse(parts[1]) : null;
  if (index == null || index < 1 || index > 12) {
    return month;
  }
  return '${names[index - 1]} ${parts[0]}';
}