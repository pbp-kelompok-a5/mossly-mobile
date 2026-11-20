String carbonNumber(num value, {int decimals = 1}) {
  final parts = value.toStringAsFixed(decimals).split('.');
  final integer = parts.first.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
  return parts.length == 1 ? integer : '$integer,${parts[1]}';
}

String carbonEmission(double value) {
  if (value == 0) return '0';
  if (value < 0.01) return '<0,01';
  return carbonNumber(value, decimals: 2);
}

String carbonDate(DateTime date) {
  const months = [
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
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
