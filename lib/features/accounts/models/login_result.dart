/// Token dari respons register/login. Profil dibaca melalui auth/me/.
class LoginResult {
  const LoginResult({required this.token});

  final String token;

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    final token = json['token'];
    if (token is! String || token.trim().isEmpty) {
      throw const FormatException(
        'Respons login tidak memuat token yang valid.',
      );
    }
    return LoginResult(token: token);
  }
}
