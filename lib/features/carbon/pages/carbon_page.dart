import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api_client.dart';
import '../../../core/theme.dart';
import '../models/carbon_history.dart';
import '../services/carbon_service.dart';
import '../widgets/carbon_cards.dart';

/// Riwayat Carbon CP1: data berasal dari DRF, bukan data contoh Figma.
class CarbonPage extends StatefulWidget {
  const CarbonPage({super.key});
  @override
  State<CarbonPage> createState() => _CarbonPageState();
}

class _CarbonPageState extends State<CarbonPage> {
  static const _sortLabels = {
    'newest': 'Terbaru lebih dulu',
    'oldest': 'Terlama lebih dulu',
    'distance': 'Jarak terjauh',
    'emission': 'Emisi tertinggi',
  };
  final _historyKey = GlobalKey();
  CarbonService? _service;
  Future<_PageData>? _future;
  String _mode = '';
  String _sort = 'newest';
  int _page = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // IndexedStack membangun semua tab; muat Carbon ketika tabnya dibuka.
    if (_service == null && Visibility.of(context)) {
      _service = CarbonService(context.read<ApiClient>());
      _future = _load();
    }
  }

  Future<_PageData> _load() async {
    final responses = await Future.wait<Object>([
      _service!.getModes(),
      _service!.getHistory(mode: _mode, sort: _sort, page: _page),
    ]);
    return _PageData(
      responses[0] as List<CarbonMode>,
      responses[1] as CarbonHistory,
    );
  }

  Future<void> _reload() async {
    final next = _load();
    setState(() {
      _future = next;
    });
    try {
      await next;
    } catch (_) {
      // FutureBuilder menampilkan error; indikator refresh tetap selesai.
    }
  }

  void _filter({String? mode, String? sort, int? page}) {
    _mode = mode ?? _mode;
    _sort = sort ?? _sort;
    _page = page ?? 1;
    _reload();
  }

  void _viewHistory() {
    final target = _historyKey.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  @override
  Widget build(BuildContext context) => _future == null
      ? const SizedBox.shrink()
      : Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Theme.of(context).colorScheme.surface,
            toolbarHeight: 64,
            titleSpacing: carbonGutter,
            title: Row(
              children: [
                Image.asset(
                  'assets/branding/mossly-mark.png',
                  width: 36,
                  height: 36,
                  excludeFromSemantics: true,
                ),
                const SizedBox(width: MosslySpace.s2),
                const Text(
                  'mossly',
                  style: TextStyle(
                    fontFamily: 'RedHatDisplay',
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: MosslyColors.moss800,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: _reload,
                tooltip: 'Muat ulang riwayat',
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: MosslyColors.moss500,
                ),
              ),
              const SizedBox(width: MosslySpace.s2),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _reload,
            child: FutureBuilder<_PageData>(
              future: _future,
              builder: (context, snapshot) {
                final loading =
                    snapshot.connectionState != ConnectionState.done;
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    carbonGutter,
                    MosslySpace.s2,
                    carbonGutter,
                    MosslySpace.s8,
                  ),
                  children: [
                    CarbonHero(onViewHistory: _viewHistory),
                    const SizedBox(height: MosslySpace.s6),
                    SizedBox(key: _historyKey),
                    if (loading)
                      _loading()
                    else if (snapshot.hasError)
                      _error(snapshot.error)
                    else
                      ..._history(snapshot.requireData),
                  ],
                );
              },
            ),
          ),
        );

  Widget _loading() => Padding(
    padding: const EdgeInsets.all(MosslySpace.s8),
    child: Column(
      children: [
        const CircularProgressIndicator(
          semanticsLabel: 'Memuat riwayat perjalanan',
        ),
        const SizedBox(height: MosslySpace.s4),
        Text('Memuat jejak perjalananmu…', style: carbonText(14)),
      ],
    ),
  );

  Widget _error(Object? error) {
    final message = switch (error) {
      ApiException(statusCode: 401) =>
        'Sesi tidak valid atau sudah berakhir. Silakan login kembali.',
      ApiException(statusCode: 429) =>
        'Terlalu banyak permintaan. Tunggu sebentar, lalu coba lagi.',
      FormatException() =>
        'Data Carbon dari server belum sesuai. Coba muat ulang riwayat.',
      _ => 'Periksa koneksi dan ketersediaan server, lalu coba lagi.',
    };
    return Container(
      decoration: carbonCardDecoration(),
      padding: const EdgeInsets.all(MosslySpace.s6),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            color: MosslyColors.moss500,
            size: 36,
          ),
          const SizedBox(height: MosslySpace.s3),
          Text(
            'Riwayat belum dapat dimuat',
            textAlign: TextAlign.center,
            style: carbonText(20, weight: FontWeight.w600),
          ),
          const SizedBox(height: MosslySpace.s2),
          Text(
            message,
            textAlign: TextAlign.center,
            style: carbonText(14, color: MosslyColors.neutral600),
          ),
          const SizedBox(height: MosslySpace.s4),
          FilledButton.icon(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }

  List<Widget> _history(_PageData data) {
    final history = data.history;
    return [
      CarbonSummaryCard(summary: history.summary),
      const SizedBox(height: MosslySpace.s8),
      Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: MosslySpace.s3,
        children: [
          const Text(
            'Riwayat perjalanan',
            style: TextStyle(
              fontFamily: 'RedHatDisplay',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: MosslyColors.moss800,
            ),
          ),
          Chip(
            label: Text('${history.summary.totalTrips}'),
            backgroundColor: MosslyColors.moss100,
            side: BorderSide.none,
          ),
        ],
      ),
      Text(
        'Jejak kecilmu, tercatat di sini.',
        style: carbonText(14, color: MosslyColors.neutral600),
      ),
      const SizedBox(height: MosslySpace.s4),
      Align(
        alignment: Alignment.centerLeft,
        child: PopupMenuButton<String>(
          tooltip: 'Urutkan riwayat',
          initialValue: _sort,
          onSelected: (value) => _filter(sort: value),
          itemBuilder: (_) => _sortLabels.entries
              .map(
                (option) => PopupMenuItem(
                  value: option.key,
                  child: Row(
                    children: [
                      Expanded(child: Text(option.value)),
                      if (option.key == _sort)
                        const Icon(Icons.check, size: 18),
                    ],
                  ),
                ),
              )
              .toList(),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: MosslySpace.s4,
              vertical: MosslySpace.s2,
            ),
            decoration: BoxDecoration(
              color: MosslyColors.sand100,
              border: Border.all(color: MosslyColors.sand300),
              borderRadius: BorderRadius.circular(MosslySpace.radiusXl),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: MosslyColors.moss500,
                ),
                const SizedBox(width: MosslySpace.s2),
                Text(
                  _sortLabels[_sort]!,
                  style: carbonText(12, weight: FontWeight.w600),
                ),
                const SizedBox(width: MosslySpace.s1),
                const Icon(Icons.expand_more, size: 18),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: MosslySpace.s3),
      Text(
        'Filter transportasi',
        style: carbonText(12, weight: FontWeight.w600),
      ),
      Wrap(
        spacing: MosslySpace.s2,
        children: [
          ChoiceChip(
            label: const Text('Semua moda'),
            selected: _mode.isEmpty,
            onSelected: (_) => _filter(mode: ''),
          ),
          for (final mode in data.modes)
            ChoiceChip(
              label: Text(mode.name),
              selected: _mode == mode.code,
              onSelected: (_) => _filter(mode: mode.code),
            ),
        ],
      ),
      if (_mode.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: MosslySpace.s2),
          child: Text(
            'Ringkasan mengikuti filter transportasi.',
            style: carbonText(12, color: MosslyColors.neutral600),
          ),
        ),
      const SizedBox(height: MosslySpace.s4),
      if (history.trips.isEmpty)
        CarbonEmptyState(
          filtered: _mode.isNotEmpty,
          onClearFilter: () => _filter(mode: ''),
        )
      else ...[
        for (final trip in history.trips)
          Padding(
            padding: const EdgeInsets.only(bottom: MosslySpace.s4),
            child: CarbonTripCard(key: ValueKey(trip.id), trip: trip),
          ),
        Text(
          history.pages == 1
              ? 'Menampilkan semua ${history.summary.totalTrips} perjalanan'
              : 'Menampilkan ${(history.page - 1) * history.perPage + 1}–${(history.page - 1) * history.perPage + history.trips.length} dari ${history.summary.totalTrips} perjalanan',
          textAlign: TextAlign.center,
          style: carbonText(12, color: MosslyColors.neutral400),
        ),
      ],
      if (history.pages > 1) ...[
        const SizedBox(height: MosslySpace.s4),
        Text(
          'Halaman ${history.page} dari ${history.pages}',
          textAlign: TextAlign.center,
          style: carbonText(13, color: MosslyColors.neutral600),
        ),
        const SizedBox(height: MosslySpace.s2),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: history.previousPage == null
                    ? null
                    : () => _filter(page: history.previousPage),
                child: const Text('Sebelumnya'),
              ),
            ),
            const SizedBox(width: MosslySpace.s3),
            Expanded(
              child: OutlinedButton(
                onPressed: history.nextPage == null
                    ? null
                    : () => _filter(page: history.nextPage),
                child: const Text('Berikutnya'),
              ),
            ),
          ],
        ),
      ],
      const SizedBox(height: MosslySpace.s6),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 18,
            color: MosslyColors.neutral600,
          ),
          const SizedBox(width: MosslySpace.s3),
          Expanded(
            child: Text(
              'Angka di atas adalah estimasi emisi langsung transportasi, bukan seluruh jejak karbonmu. Sepeda dan jalan kaki dihitung nol emisi langsung.',
              style: carbonText(12, color: MosslyColors.neutral600),
            ),
          ),
        ],
      ),
    ];
  }
}

class _PageData {
  const _PageData(this.modes, this.history);
  final List<CarbonMode> modes;
  final CarbonHistory history;
}
