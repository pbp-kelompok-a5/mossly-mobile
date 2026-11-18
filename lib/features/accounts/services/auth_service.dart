import 'dart:async';

import 'package:http/http.dart' as http;

import '../../../core/api_client.dart';
import '../models/account_user.dart';
import '../models/login_result.dart';

enum AuthAction { login, register, logout, profile }

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
    final data = await _withTimeout(
      _api.post(
        '/auth/login/',
        body: {'username': username.trim(), 'password': password},
      ),
    );
    return _sessionResult(data, 'masuk');
  }

  Future<LoginResult> register({
    required String username,
    required String email,
    required String displayName,
    required int age,
    required String password,
    required String passwordConfirmation,
  }) async {
    final data = await _withTimeout(
      _api.post(
        '/auth/register/',
        body: {
          'username': username.trim(),
          'email': email.trim(),
          'display_name': displayName.trim(),
          'umur': age,
          'password1': password,
          'password2': passwordConfirmation,
        },
      ),
    );
    return _sessionResult(data, 'pendaftaran');
  }

  Future<AccountUser> getProfile() async {
    final data = await _withTimeout(_api.get('/auth/me/'));
    if (data is! Map<String, dynamic>) {
      throw const AuthException(
        'Respons profil tidak valid. Silakan coba lagi.',
      );
    }
    try {
      return AccountUser.fromJson(data);
    } on FormatException {
      throw const AuthException(
        'Respons profil tidak valid. Silakan coba lagi.',
      );
    }
  }

  /// HTTP 401 berarti token sudah tidak berlaku; sesi lokal boleh dibersihkan.
  Future<void> logout() async {
    try {
      await _withTimeout(_api.post('/auth/logout/'));
    } on ApiException catch (error) {
      if (error.statusCode != 401) {
        rethrow;
      }
    }
  }

  LoginResult _sessionResult(dynamic data, String action) {
    if (data is Map<String, dynamic>) {
      try {
        return LoginResult.fromJson(data);
      } on FormatException {
        // Jangan menyimpan sesi jika server mengirim token kosong atau rusak.
      }
    }
    throw AuthException('Respons $action tidak valid. Silakan coba lagi.');
  }

  Future<dynamic> _withTimeout(Future<dynamic> request) async {
    try {
      return await request.timeout(_timeout);
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
String authErrorMessage(Object error, {required AuthAction action}) {
  if (error is AuthException) {
    return error.message;
  }
  if (error is ApiException) {
    if (error.statusCode == 404) {
      final feature = switch (action) {
        AuthAction.login => 'masuk',
        AuthAction.register => 'pendaftaran',
        AuthAction.logout => 'keluar',
        AuthAction.profile => 'profil',
      };
      return 'Layanan $feature belum tersedia. Silakan coba lagi nanti.';
    }
    if (error.statusCode >= 500) {
      return 'Server sedang bermasalah. Silakan coba lagi nanti.';
    }
    final body = error.body;
    if (body is Map) {
      const labels = {
        'detail': '',
        'non_field_errors': '',
        'username': 'Username',
        'email': 'Email',
        'display_name': 'Nama tampilan',
        'umur': 'Umur',
        'password': 'Kata sandi',
        'password1': 'Kata sandi',
        'password2': 'Konfirmasi kata sandi',
      };
      final messages = <String>[];
      for (final entry in labels.entries) {
        final value = body[entry.key];
        final lines = value is String
            ? [value]
            : value is List
            ? value.whereType<String>()
            : <String>[];
        for (final line in lines.where((s) => s.trim().isNotEmpty)) {
          messages.add(entry.value.isEmpty ? line : '${entry.value}: $line');
        }
      }
      if (messages.isNotEmpty) {
        return messages.join('\n');
      }
    }
    if (action == AuthAction.login &&
        (error.statusCode == 400 || error.statusCode == 401)) {
      return 'Username atau kata sandi salah.';
    }
    return 'Permintaan belum berhasil. Silakan coba lagi.';
  }
  return 'Terjadi kendala. Silakan coba lagi.';
}
