/// Pengaturan aplikasi.
class AppConfig {
  /// Alamat situs web Django. Default-nya PWS kelompok.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://tania-ju-mossly.pws.cs.ui.ac.id',
  );

  /// Semua endpoint Django REST Framework berada di bawah awalan ini.
  static const String apiPrefix = '/api/v1';

  /// Token untuk pengembangan, dipakai selama halaman login belum selesai.
  /// python manage.py drf_create_token <username>
  static const String devToken = String.fromEnvironment('DEV_TOKEN');
}
