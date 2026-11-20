import '../../../core/api_client.dart';
import '../models/carbon_history.dart';

/// Semua request memakai klien bersama, termasuk header token dari Session.
class CarbonService {
  const CarbonService(this.api);

  final ApiClient api;

  Future<List<CarbonMode>> getModes() async {
    final response = carbonObject(await api.get('/carbon/modes/'));
    final modes = response['modes'];
    if (modes is! List) {
      throw const FormatException('Daftar transportasi tidak valid.');
    }
    return List.unmodifiable(
      modes.map((item) => CarbonMode.fromJson(carbonObject(item))),
    );
  }

  Future<CarbonHistory> getHistory({
    String mode = '',
    String sort = 'newest',
    int page = 1,
  }) async {
    final response = await api.get(
      '/carbon/trips/',
      query: {if (mode.isNotEmpty) 'mode': mode, 'sort': sort, 'page': page},
    );
    return CarbonHistory.fromJson(carbonObject(response));
  }
}
