/// Kontrak JSON dua endpoint Carbon Checkpoint 1.
/// Angka tetap dibaca sebagai angka; data rusak tidak diganti dengan nol.
class CarbonMode {
  const CarbonMode({required this.code, required this.name});

  final String code;
  final String name;

  factory CarbonMode.fromJson(Map<String, dynamic> json) =>
      CarbonMode(code: _text(json, 'code'), name: _text(json, 'name'));
}

class CarbonTrip {
  const CarbonTrip({
    required this.id,
    required this.date,
    required this.origin,
    required this.destination,
    required this.modeCode,
    required this.modeName,
    required this.distanceKm,
    required this.emissionKg,
    required this.note,
  });

  final int id;
  final DateTime date;
  final String origin;
  final String destination;
  final String modeCode;
  final String modeName;
  final double distanceKm;
  final double emissionKg;
  final String note;

  factory CarbonTrip.fromJson(Map<String, dynamic> json) {
    final rawDate = _text(json, 'date');
    final date = DateTime.tryParse(rawDate);
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(rawDate) ||
        date == null ||
        date.toIso8601String().split('T').first != rawDate) {
      throw const FormatException('Tanggal perjalanan tidak valid.');
    }
    return CarbonTrip(
      id: _integer(json, 'id', minimum: 1),
      date: date,
      origin: _text(json, 'origin'),
      destination: _text(json, 'destination'),
      modeCode: _text(json, 'mode_code'),
      modeName: _text(json, 'mode_display'),
      distanceKm: _number(json, 'distance_km'),
      emissionKg: _number(json, 'emission_kg'),
      note: _text(json, 'note', allowEmpty: true),
    );
  }
}

class CarbonSummary {
  const CarbonSummary({
    required this.totalTrips,
    required this.totalDistanceKm,
    required this.totalEmissionKg,
  });

  final int totalTrips;
  final double totalDistanceKm;
  final double totalEmissionKg;

  factory CarbonSummary.fromJson(Map<String, dynamic> json) => CarbonSummary(
    totalTrips: _integer(json, 'total_trips'),
    totalDistanceKm: _number(json, 'total_distance_km'),
    totalEmissionKg: _number(json, 'total_co2e_kg'),
  );
}

class CarbonHistory {
  const CarbonHistory({
    required this.trips,
    required this.summary,
    required this.page,
    required this.pages,
    required this.perPage,
    required this.previousPage,
    required this.nextPage,
  });

  final List<CarbonTrip> trips;
  final CarbonSummary summary;
  final int page;
  final int pages;
  final int perPage;
  final int? previousPage;
  final int? nextPage;

  factory CarbonHistory.fromJson(Map<String, dynamic> json) {
    final rawTrips = json['trips'];
    if (rawTrips is! List) {
      throw const FormatException('Daftar perjalanan tidak valid.');
    }
    final pagination = carbonObject(json['pagination']);
    final summary = CarbonSummary.fromJson(carbonObject(json['summary']));
    final page = _integer(pagination, 'page', minimum: 1);
    final pages = _integer(pagination, 'pages', minimum: 1);
    final perPage = _integer(pagination, 'per_page', minimum: 1);
    final count = _integer(pagination, 'count');
    final previous = pagination['previous_page'] == null
        ? null
        : _integer(pagination, 'previous_page', minimum: 1);
    final next = pagination['next_page'] == null
        ? null
        : _integer(pagination, 'next_page', minimum: 1);
    final trips = rawTrips
        .map((item) => CarbonTrip.fromJson(carbonObject(item)))
        .toList(growable: false);
    final expectedPages = count == 0 ? 1 : (count + perPage - 1) ~/ perPage;
    final remaining = count - (page - 1) * perPage;
    final expectedLength = remaining > perPage ? perPage : remaining;
    if (page > pages ||
        count != summary.totalTrips ||
        pages != expectedPages ||
        trips.length != expectedLength ||
        trips.map((trip) => trip.id).toSet().length != trips.length ||
        previous != (page > 1 ? page - 1 : null) ||
        next != (page < pages ? page + 1 : null)) {
      throw const FormatException('Pagination riwayat tidak sesuai.');
    }
    return CarbonHistory(
      trips: List.unmodifiable(trips),
      summary: summary,
      page: page,
      pages: pages,
      perPage: perPage,
      previousPage: previous,
      nextPage: next,
    );
  }
}

Map<String, dynamic> carbonObject(Object? value) {
  if (value is! Map<String, dynamic>) {
    throw const FormatException('Respons Carbon bukan objek JSON.');
  }
  return value;
}

String _text(Map<String, dynamic> json, String key, {bool allowEmpty = false}) {
  final value = json[key];
  if (value is! String || (!allowEmpty && value.trim().isEmpty)) {
    throw FormatException('Field $key tidak valid.');
  }
  return value;
}

double _number(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! num || !value.isFinite || value < 0) {
    throw FormatException('Field $key harus berupa angka nonnegatif.');
  }
  return value.toDouble();
}

int _integer(Map<String, dynamic> json, String key, {int minimum = 0}) {
  final value = json[key];
  if (value is! int || value < minimum) {
    throw FormatException('Field $key harus berupa bilangan bulat.');
  }
  return value;
}
