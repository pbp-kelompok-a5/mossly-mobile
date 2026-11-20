import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../models/goal.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import '../widgets/async_states.dart';
import '../widgets/goal_card.dart';
import '../widgets/habit_tile.dart';

/// Halaman utama modul Sustainable Habit & Goal Tracker
///
/// Dua tab: Habit (GET /habits/) dan Goal (GET /goals/)
/// Setiap tab memuat datanya sendiri dengan FutureBuilder dan bisa ditarik untuk memuat ulang
class HabitsPage extends StatelessWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Habit & Goal'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.repeat), text: 'Habit'),
              Tab(icon: Icon(Icons.flag_outlined), text: 'Goal'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _AsyncTab<HabitOverview>(
              load: (service) => service.fetchHabits(),
              isEmpty: (overview) => overview.habits.isEmpty,
              empty: const EmptyState(
                icon: Icons.eco_outlined,
                title: 'Belum ada habit',
                message: 'Fitur tambah habit akan segera dibuat',
              ),
              builder: (overview) => _HabitList(overview: overview),
            ),
            _AsyncTab<List<Goal>>(
              load: (service) => service.fetchGoals(),
              isEmpty: (goals) => goals.isEmpty,
              empty: const EmptyState(
                icon: Icons.flag_outlined,
                title: 'Belum ada goal',
                message: 'Fitur tambah goal akan segera dibuat',
              ),
              builder: (goals) => _GoalList(goals: goals),
            ),
          ],
        ),
      ),
    );
  }
}

/// Satu tab yang memuat data dari server, kondisi: gagal / kosong / berisi
class _AsyncTab<T> extends StatefulWidget {
  const _AsyncTab({
    super.key,
    required this.load,
    required this.isEmpty,
    required this.empty,
    required this.builder,
  });

  /// Fungsi service yang dipanggil
  final Future<T> Function(HabitService service) load;
  final bool Function(T data) isEmpty;
  final Widget empty;
  final Widget Function(T data) builder;

  @override
  State<_AsyncTab<T>> createState() => _AsyncTabState<T>();
}

class _AsyncTabState<T> extends State<_AsyncTab<T>>
    with AutomaticKeepAliveClientMixin {
  // Future disimpan di State, bukan dibuat di build(), supaya request tidak kekirim ulang tiap widget di-rebuild
  Future<T>? _future;

  // Data tidak hilang (dan tidak dimuat ulang) saat berpindah tab Habit/Goal
  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // HomeShell memakai IndexedStack yang membangun semua tab sekaligus
    // Visibility.of bernilai false selama tab Habit belum dibuka
    // Request pertama baru dikirim saat halaman ini dibuka, Flutter memanggil didChangeDependencies
    if (_future == null && Visibility.of(context)) {
      _future = widget.load(HabitService.of(context));
    }
  }

  /// Dipanggil oleh RefreshIndicator (tarik ke bawah) dan tombol "Coba lagi"
  Future<void> _reload() {
    final future = widget.load(HabitService.of(context));
    setState(() {
      _future = future;
    });
    // RefreshIndicator menunggu Future ini selesai untuk menyembunyikan ikon loading
    return future.then((_) {}, onError: (_) {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // wajib untuk AutomaticKeepAliveClientMixin
    return RefreshIndicator(
      onRefresh: _reload,
      child: FutureBuilder<T>(
        future: _future,
        builder: (context, snapshot) {
          // none: tab belum pernah terlihat, belum ada request
          if (snapshot.connectionState == ConnectionState.none) {
            return const SizedBox.shrink();
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingState();
          }
          if (snapshot.hasError) {
            return ErrorState(message: '${snapshot.error}', onRetry: _reload);
          }
          final data = snapshot.data as T;
          if (widget.isEmpty(data)) {
            return widget.empty;
          }
          return widget.builder(data);
        },
      ),
    );
  }
}

/// Ringkasan hari ini di atas, lalu satu HabitTile per habit
class _HabitList extends StatelessWidget {
  const _HabitList({required this.overview});

  final HabitOverview overview;

  @override
  Widget build(BuildContext context) {
    final habits = overview.habits;
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(MosslySpace.s4),
      itemCount: habits.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: MosslySpace.s3),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _TodaySummary(overview: overview);
        }
        return HabitTile(habit: habits[index - 1]);
      },
    );
  }
}

class _TodaySummary extends StatelessWidget {
  const _TodaySummary({required this.overview});

  final HabitOverview overview;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final scheduled = overview.scheduledToday;
    final done = overview.doneToday;
    return Container(
      padding: const EdgeInsets.all(MosslySpace.s4),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(MosslySpace.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hari ini',
            style: text.labelLarge?.copyWith(color: scheme.onPrimaryContainer),
          ),
          const SizedBox(height: MosslySpace.s1),
          Text(
            scheduled == 0
                ? 'Tidak ada habit terjadwal'
                : '$done dari $scheduled habit selesai',
            style: text.titleLarge?.copyWith(color: scheme.onPrimaryContainer),
          ),
          if (scheduled > 0) ...[
            const SizedBox(height: MosslySpace.s3),
            ClipRRect(
              borderRadius: BorderRadius.circular(MosslySpace.radiusSm),
              child: LinearProgressIndicator(
                value: done / scheduled,
                minHeight: MosslySpace.s2,
                backgroundColor: scheme.surfaceContainerLowest,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GoalList extends StatelessWidget {
  const _GoalList({required this.goals});

  final List<Goal> goals;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(MosslySpace.s4),
      itemCount: goals.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: MosslySpace.s3),
      itemBuilder: (context, index) {
        if (index == 0) {
          return const _GoalHeader();
        }
        return GoalCard(goal: goals[index - 1]);
      },
    );
  }
}

/// Kartu sapaan di atas daftar goal, gayanya sama dengan _TodaySummary.
class _GoalHeader extends StatelessWidget {
  const _GoalHeader();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(MosslySpace.s4),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(MosslySpace.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Goal',
            style: text.labelLarge?.copyWith(color: scheme.onPrimaryContainer),
          ),
          const SizedBox(height: MosslySpace.s1),
          Text(
            'Goal kamu, semangat ya!',
            style: text.titleLarge?.copyWith(color: scheme.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}
