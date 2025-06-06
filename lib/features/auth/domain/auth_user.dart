class AuthUser {
  final String id;
  final String email;
  final String name;
  final String picture;
  final DateTime createdAt;
  final String jwt;

  AuthUser({
    required this.id,
    required this.email,
    required this.name,
    required this.picture,
    required this.createdAt,
    required this.jwt,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      picture: json['picture'],
      createdAt: DateTime.parse(json['createdAt']),
      jwt: json['jwt'],
    );
  }

  factory AuthUser.fromApiResponse(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return AuthUser(
      id: data['id'] as String,
      email: data['email'] as String,
      name: data['name'] as String,
      picture: data['picture'] as String,
      createdAt: DateTime.parse(data['createdAt'] as String),
      jwt: json['jwt'] as String,
    );
  }
}
