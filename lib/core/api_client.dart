import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'session.dart';

/// Dilempar saat server membalas dengan status selain 2xx
class ApiException implements Exception {
  ApiException(this.statusCode, this.message, [this.body]);

  final int statusCode;
  final String message;

  /// JSON balasan, misalnya {"nama_field": ["pesan"]} untuk validasi gagal
  final Object? body;

  @override
  String toString() => message;
}

/// Cara aplikasi berbicara dengan web service Django
/// Contoh cara pemakaian di dalam widget:
///   `final api = context.read<ApiClient>();`
///   final data = await api.get('/habits/');
///   await api.post('/habits/', body: {'name': 'Bawa tumbler'});
///
/// [path] ditulis tanpa awalan /api/v1 dan diakhiri garis miring
class ApiClient {
  ApiClient(this._session, {http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final Session _session;
  final http.Client _http;

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    return _decode(await _http.get(_uri(path, query), headers: _headers));
  }

  Future<dynamic> post(String path, {Object? body}) async {
    return _decode(await _http.post(
      _uri(path),
      headers: _headers,
      body: jsonEncode(body ?? <String, dynamic>{}),
    ));
  }

  Future<dynamic> patch(String path, {Object? body}) async {
    return _decode(await _http.patch(
      _uri(path),
      headers: _headers,
      body: jsonEncode(body ?? <String, dynamic>{}),
    ));
  }

  Future<dynamic> delete(String path) async {
    return _decode(await _http.delete(_uri(path), headers: _headers));
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final uri = Uri.parse('${AppConfig.baseUrl}${AppConfig.apiPrefix}$path');
    if (query == null || query.isEmpty) {
      return uri;
    }
    return uri.replace(
      queryParameters: query.map((key, value) => MapEntry(key, '$value')),
    );
  }

  Map<String, String> get _headers {
    final token = _session.token;
    return <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };
  }

  dynamic _decode(http.Response response) {
    final text = utf8.decode(response.bodyBytes);
    dynamic data;
    if (text.isNotEmpty) {
      try {
        data = jsonDecode(text);
      } on FormatException {
        data = null;
      }
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }
    var message = 'Permintaan gagal (${response.statusCode}).';
    if (data is Map && data['detail'] is String) {
      message = data['detail'] as String;
    }
    throw ApiException(response.statusCode, message, data);
  }
}
