import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

/// Menyimpan token login di perangkat dan memberi tahu UI saat berubah.
class Session extends ChangeNotifier {
  static const String _tokenKey = 'auth_token';

  String? _token;

  String? get token => _token;
  bool get isLoggedIn => _token != null;

  /// Dipanggil sekali saat aplikasi dibuka
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    if (_token == null && AppConfig.devToken.isNotEmpty) {
      _token = AppConfig.devToken;
    }
    notifyListeners();
  }

  /// Dipanggil setelah login atau registrasi berhasil
  Future<void> signIn(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    _token = token;
    notifyListeners();
  }

  /// Dipanggil saat logout
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    _token = null;
    notifyListeners();
  }
}
