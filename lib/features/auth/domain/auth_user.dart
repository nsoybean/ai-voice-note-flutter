class AuthUser {
  final String id;
  final String email;
  final String name;

  AuthUser({required this.id, required this.email, required this.name});

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(id: json['id'], email: json['email'], name: json['name']);
  }
}
