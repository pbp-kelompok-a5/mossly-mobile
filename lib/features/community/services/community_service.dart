import 'dart:async';

import 'package:http/http.dart' as http;

import '../../../core/api_client.dart';
import '../models/community_feed.dart';
import '../models/community_thread.dart';

class CommunityException implements Exception {
  const CommunityException(this.message);
  final String message;
}

/// Widget memberikan klien lewat `context.read<ApiClient>()`. Token dan awalan
/// /api/v1 ditangani ApiClient bersama, tanpa menyimpan token di modul ini.
class CommunityService {
  CommunityService(this._api);
  final ApiClient _api;
  static const _timeout = Duration(seconds: 20);

  Future<CommunityFeed> getThreads({
    String category = '',
    String author = '',
    int page = 1,
  }) => _get(
    '/community/threads/',
    CommunityFeed.fromJson,
    query: {
      if (category.isNotEmpty) 'category': category,
      if (author.trim().isNotEmpty) 'author': author.trim(),
      'page': page,
    },
  );

  Future<CommunityThread> getThread(int id) =>
      _get('/community/threads/$id/', CommunityThread.fromJson);

  Future<T> _get<T>(
    String path,
    T Function(Map<String, dynamic>) decode, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final data = await _api.get(path, query: query).timeout(_timeout);
      if (data is! Map<String, dynamic>) {
        throw const FormatException();
      }
      return decode(data);
    } on TimeoutException {
      throw const CommunityException(
        'Server belum merespons. Silakan coba lagi.',
      );
    } on http.ClientException {
      throw const CommunityException(
        'Tidak dapat terhubung. Periksa koneksi lalu coba lagi.',
      );
    } on FormatException {
      throw const CommunityException(
        'Data komunitas belum dapat ditampilkan. Silakan coba lagi.',
      );
    }
  }
}

String communityErrorMessage(Object error) {
  if (error is CommunityException) return error.message;
  if (error is ApiException) {
    if (error.statusCode == 401) {
      return 'Sesi kamu sudah berakhir. Silakan masuk kembali.';
    }
    if (error.statusCode == 404) {
      return 'Cerita atau halaman ini sudah tidak tersedia.';
    }
    if (error.statusCode == 429) {
      return 'Terlalu banyak permintaan. Coba lagi sebentar lagi.';
    }
    if (error.statusCode >= 500) {
      return 'Server sedang bermasalah. Silakan coba lagi nanti.';
    }
    if (error.statusCode == 400 && error.body is Map) {
      final body = error.body as Map;
      final messages = <String>[
        for (final key in ['category', 'author', 'page'])
          if (body[key] is List) ...(body[key] as List).whereType<String>(),
      ];
      if (messages.isNotEmpty) return messages.join('\n');
    }
  }
  return 'Komunitas belum dapat dimuat. Silakan coba lagi.';
}
