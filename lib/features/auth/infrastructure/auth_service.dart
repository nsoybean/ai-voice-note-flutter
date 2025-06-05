import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../domain/auth_user.dart';

final authServiceProvider = Provider<AuthService>((_) => AuthService());

class AuthService {
  Future<AuthUser?> signInWithGoogle() async {
    final res = await http.get(
      Uri.parse('http://127.0.0.1:3000/'),
      // headers: {'Content-Type': 'application/json'},
      // body: jsonEncode({/* your auth token here */}),
    );

    print("🚀 AuthService ${res.body}");

    if (res.statusCode == 200) {
      return AuthUser.fromJson(jsonDecode(res.body));
    }

    return null;
  }
}
