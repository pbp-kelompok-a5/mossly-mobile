import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../models/carbon_history.dart';
import 'carbon_format.dart';

const carbonAssets = 'lib/features/carbon/assets';
const carbonGutter = MosslySpace.s4 + MosslySpace.s1;

TextStyle carbonText(double size, {Color? color, FontWeight? weight}) =>
    TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: size,
      height: 1.5,
      color: color ?? MosslyColors.moss800,
      fontWeight: weight,
    );

BoxDecoration carbonCardDecoration() => BoxDecoration(
  color: MosslyColors.neutral0,
  borderRadius: BorderRadius.circular(MosslySpace.radiusXl),
  border: Border.all(color: MosslyColors.sand200),
  boxShadow: [
    BoxShadow(
      color: MosslyColors.moss900.withValues(alpha: 0.07),
      blurRadius: MosslySpace.s1,
      offset: const Offset(0, 2),
    ),
  ],
);

class CarbonHero extends StatelessWidget {
  const CarbonHero({super.key, required this.onViewHistory});
  final VoidCallback onViewHistory;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(MosslySpace.radiusXl),
    child: ColoredBox(
      color: MosslyColors.moss500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              MosslySpace.s6,
              MosslySpace.s6,
              MosslySpace.s6,
              MosslySpace.s2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CARBON FOOTPRINT TRACKER',
                  style: carbonText(
                    12,
                    color: MosslyColors.sand300,
                    weight: FontWeight.w700,
                  ).copyWith(letterSpacing: 1.1),
                ),
                const SizedBox(height: MosslySpace.s4),
                const Text(
                  'Setiap perjalanan punya jejak.',
                  style: TextStyle(
                    fontFamily: 'RedHatDisplay',
                    fontSize: 40,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                    color: MosslyColors.sand50,
                  ),
                ),
                const SizedBox(height: MosslySpace.s3),
                Text(
                  'Catat perjalananmu dan kenali estimasi emisi transportasi sehari-hari.',
                  style: carbonText(16, color: MosslyColors.sand50),
                ),
                const SizedBox(height: MosslySpace.s3),
                FilledButton.icon(
                  onPressed: onViewHistory,
                  style: FilledButton.styleFrom(
                    backgroundColor: MosslyColors.sand50,
                    foregroundColor: MosslyColors.moss800,
                    padding: const EdgeInsets.symmetric(
                      horizontal: MosslySpace.s6,
                      vertical: MosslySpace.s3,
                    ),
                  ),
                  icon: const Icon(Icons.south_rounded, size: 18),
                  label: Text(
                    'Lihat riwayat',
                    style: carbonText(14, weight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          ExcludeSemantics(
            child: AspectRatio(
              aspectRatio: 350 / 241,
              child: Image.asset(
                '$carbonAssets/hero-mobile.png',
                fit: BoxFit.fitWidth,
                width: double.infinity,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class CarbonSummaryCard extends StatelessWidget {
  const CarbonSummaryCard({super.key, required this.summary});
  final CarbonSummary summary;

  @override
  Widget build(BuildContext context) => Container(
    decoration: carbonCardDecoration(),
    padding: const EdgeInsets.all(carbonGutter),
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _stat(
            'Jumlah',
            carbonNumber(summary.totalTrips, decimals: 0),
            'perjalanan',
            'stat-route-mobile',
          ),
          _divider(),
          _stat(
            'Total jarak',
            carbonNumber(summary.totalDistanceKm),
            'km',
            'stat-pin-mobile',
          ),
          _divider(),
          _stat(
            'Estimasi emisi',
            carbonEmission(summary.totalEmissionKg),
            'kg CO₂e',
            'stat-leaf-mobile',
          ),
        ],
      ),
    ),
  );

  Widget _divider() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: MosslySpace.s3),
    child: VerticalDivider(width: 1, thickness: 1, color: MosslyColors.sand200),
  );

  Widget _stat(String title, String value, String unit, String icon) =>
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Container(
                width: 36,
                height: 36,
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: icon == 'stat-leaf-mobile'
                      ? MosslyColors.clay100
                      : MosslyColors.moss100,
                  borderRadius: BorderRadius.circular(MosslySpace.radiusMd),
                ),
                child: Image.asset(
                  '$carbonAssets/$icon.png',
                  width: 18,
                  height: 18,
                ),
              ),
            ),
            const SizedBox(height: MosslySpace.s1),
            Text(title, style: carbonText(11, weight: FontWeight.w600)),
            const SizedBox(height: MosslySpace.s1),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: carbonText(28, weight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: MosslySpace.s1),
            Text(unit, style: carbonText(12, color: MosslyColors.neutral600)),
          ],
        ),
      );
}

class CarbonTripCard extends StatelessWidget {
  const CarbonTripCard({super.key, required this.trip});
  final CarbonTrip trip;

  @override
  Widget build(BuildContext context) => Container(
    decoration: carbonCardDecoration(),
    padding: const EdgeInsets.all(carbonGutter),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: MosslyColors.moss50,
                borderRadius: BorderRadius.circular(MosslySpace.radiusMd),
              ),
              padding: const EdgeInsets.all(MosslySpace.s3),
              child: _modeIcon(),
            ),
            const SizedBox(width: MosslySpace.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.modeName,
                    style: carbonText(20, weight: FontWeight.w600),
                  ),
                  Text(
                    carbonDate(trip.date),
                    style: carbonText(13, color: MosslyColors.neutral600),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: MosslySpace.s4),
        _location(trip.origin, MosslyColors.moss500, first: true),
        _location(trip.destination, MosslyColors.clay500),
        if (trip.note.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: MosslySpace.s3),
            child: Container(
              padding: const EdgeInsets.only(left: MosslySpace.s3),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: MosslyColors.sand300, width: 3),
                ),
              ),
              child: Text(
                trip.note,
                style: carbonText(13, color: MosslyColors.neutral600),
              ),
            ),
          ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: MosslySpace.s4),
          child: Divider(height: 1, color: MosslyColors.sand200),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _metric('Jarak', carbonNumber(trip.distanceKm), 'km'),
            ),
            const SizedBox(width: MosslySpace.s3),
            Expanded(
              child: _metric(
                'Estimasi emisi',
                carbonEmission(trip.emissionKg),
                'kg CO₂e',
              ),
            ),
          ],
        ),
        if (trip.emissionKg == 0)
          Padding(
            padding: const EdgeInsets.only(top: MosslySpace.s3),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: MosslySpace.s3,
                vertical: MosslySpace.s2,
              ),
              decoration: BoxDecoration(
                color: MosslyColors.moss100,
                borderRadius: BorderRadius.circular(MosslySpace.radiusXl),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.eco_outlined,
                    size: 16,
                    color: MosslyColors.moss500,
                  ),
                  const SizedBox(width: MosslySpace.s2),
                  Flexible(
                    child: Text(
                      'Nol emisi langsung',
                      style: carbonText(
                        11,
                        color: MosslyColors.moss500,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );

  Widget _modeIcon() {
    const icons = {
      'mobil': 'history-mobil-mobile',
      'motor': 'history-motor-mobile',
      'sepeda': 'history-sepeda-mobile',
      'jalan': 'jalan',
    };
    final icon = icons[trip.modeCode];
    return ExcludeSemantics(
      child: icon == null
          ? const Icon(
              Icons.route_outlined,
              color: MosslyColors.moss500,
              size: 24,
            )
          : Image.asset('$carbonAssets/$icon.png', width: 24, height: 24),
    );
  }

  Widget _location(String label, Color color, {bool first = false}) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 12,
        child: Column(
          children: [
            const SizedBox(height: MosslySpace.s2),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            if (first)
              Container(
                width: 2,
                height: MosslySpace.s4,
                color: MosslyColors.sand300,
              ),
          ],
        ),
      ),
      const SizedBox(width: MosslySpace.s3),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(bottom: MosslySpace.s2),
          child: Text(label, style: carbonText(14)),
        ),
      ),
    ],
  );

  Widget _metric(String title, String value, String unit) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: carbonText(12, color: MosslyColors.neutral600)),
      const SizedBox(height: MosslySpace.s1),
      Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: MosslySpace.s1,
        children: [
          Text(value, style: carbonText(26, weight: FontWeight.w600)),
          Text(unit, style: carbonText(12, color: MosslyColors.neutral600)),
        ],
      ),
    ],
  );
}

class CarbonEmptyState extends StatelessWidget {
  const CarbonEmptyState({
    super.key,
    required this.filtered,
    required this.onClearFilter,
  });
  final bool filtered;
  final VoidCallback onClearFilter;

  @override
  Widget build(BuildContext context) => Container(
    decoration: carbonCardDecoration(),
    padding: const EdgeInsets.all(MosslySpace.s6),
    child: Column(
      children: [
        ExcludeSemantics(
          child: Image.asset(
            '$carbonAssets/empty-trip.png',
            width: 160,
            height: 120,
          ),
        ),
        const SizedBox(height: MosslySpace.s4),
        Text(
          filtered
              ? 'Tidak ada perjalanan untuk moda ini'
              : 'Belum ada perjalanan',
          textAlign: TextAlign.center,
          style: carbonText(20, weight: FontWeight.w600),
        ),
        const SizedBox(height: MosslySpace.s2),
        Text(
          filtered
              ? 'Pilih moda lain atau lihat semua perjalananmu.'
              : 'Perjalanan yang kamu catat di Mossly akan tampil di sini.',
          textAlign: TextAlign.center,
          style: carbonText(14, color: MosslyColors.neutral600),
        ),
        if (filtered)
          Padding(
            padding: const EdgeInsets.only(top: MosslySpace.s4),
            child: OutlinedButton(
              onPressed: onClearFilter,
              child: const Text('Lihat semua perjalanan'),
            ),
          ),
      ],
    ),
  );
}
