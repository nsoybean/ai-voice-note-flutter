import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../domain/auth_user.dart';

final authServiceProvider = Provider<AuthService>((_) => AuthService());

class AuthService {
  Future<AuthUser?> signInWithGoogle() async {
    // For demo: mock response from your backend
    final res = await http.post(
      Uri.parse('https://http://127.0.0.1:3000/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({/* your auth token here */}),
    );

    if (res.statusCode == 200) {
      return AuthUser.fromJson(jsonDecode(res.body));
    }

    return null;
  }
}
