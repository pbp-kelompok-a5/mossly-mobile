import 'dart:async';

import 'package:http/http.dart' as http;

import '../../../core/api_client.dart';
import '../models/login_result.dart';

/// Pesan kegagalan autentikasi yang dapat ditampilkan ke pengguna.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;
}

/// Menggunakan ApiClient bersama agar alamat API dan header token konsisten.
class AuthService {
  AuthService(this._api);

  final ApiClient _api;
  static const _timeout = Duration(seconds: 20);

  Future<LoginResult> login(String username, String password) async {
    final data = await _request(
      '/auth/login/',
      body: {'username': username.trim(), 'password': password},
    );
    if (data is! Map<String, dynamic>) {
      throw const AuthException(
        'Respons masuk tidak valid. Silakan coba lagi.',
      );
    }
    try {
      return LoginResult.fromJson(data);
    } on FormatException {
      throw const AuthException(
        'Respons masuk tidak valid. Silakan coba lagi.',
      );
    }
  }

  /// Token dicabut di server sebelum sesi lokal dihapus oleh pemanggil.
  /// HTTP 401 berarti token sudah tidak berlaku; sesi lokal boleh dibersihkan.
  Future<void> logout() async {
    try {
      await _request('/auth/logout/');
    } on ApiException catch (error) {
      if (error.statusCode != 401) {
        rethrow;
      }
    }
  }

  Future<dynamic> _request(String path, {Object? body}) async {
    try {
      return await _api.post(path, body: body).timeout(_timeout);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const AuthException('Server belum merespons. Silakan coba lagi.');
    } on http.ClientException {
      throw const AuthException(
        'Tidak dapat terhubung ke server. Periksa koneksi lalu coba lagi.',
      );
    }
  }
}

/// DRF dapat mengirim `detail`, `non_field_errors`, atau error per field.
String authErrorMessage(Object error, {required bool loggingIn}) {
  if (error is AuthException) {
    return error.message;
  }
  if (error is ApiException) {
    if (error.statusCode == 404) {
      return loggingIn
          ? 'Layanan masuk belum tersedia. Silakan coba lagi nanti.'
          : 'Layanan keluar belum tersedia. Silakan coba lagi nanti.';
    }
    if (error.statusCode >= 500) {
      return 'Server sedang bermasalah. Silakan coba lagi nanti.';
    }
    final body = error.body;
    if (body is Map) {
      final messages = <String>[];
      for (final key in [
        'detail',
        'non_field_errors',
        'username',
        'password',
      ]) {
        final value = body[key];
        if (value is String && value.trim().isNotEmpty) {
          messages.add(value);
        } else if (value is List) {
          messages.addAll(value.whereType<String>().where((s) => s.isNotEmpty));
        }
      }
      if (messages.isNotEmpty) {
        return messages.join('\n');
      }
    }
    if (loggingIn && (error.statusCode == 400 || error.statusCode == 401)) {
      return 'Username atau kata sandi salah.';
    }
    return 'Permintaan belum berhasil. Silakan coba lagi.';
  }
  return 'Terjadi kendala. Silakan coba lagi.';
}
