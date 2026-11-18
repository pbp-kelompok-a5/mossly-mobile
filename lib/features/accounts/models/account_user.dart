/// Data akun sendiri dari GET /api/v1/auth/me/.
class AccountUser {
  const AccountUser({
    required this.id,
    required this.username,
    required this.email,
    required this.displayName,
    this.age,
  });

  final int id;
  final String username;
  final String email;
  final String displayName;
  final int? age;

  factory AccountUser.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final username = json['username'];
    final email = json['email'];
    final displayName = json['display_name'];
    final age = json['umur'];
    if (id is! int ||
        username is! String ||
        username.isEmpty ||
        email is! String ||
        (age != null && age is! int)) {
      throw const FormatException('Data akun tidak valid.');
    }
    return AccountUser(
      id: id,
      username: username,
      email: email,
      displayName: displayName is String && displayName.trim().isNotEmpty
          ? displayName
          : username,
      age: age as int?,
    );
  }
}
