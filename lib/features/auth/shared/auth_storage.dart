// Token & user data storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/auth_user.dart';

class AuthStorage {
  final _secureStorage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'access_token', value: token);
  }

  Future<String?> getToken() async {
    // return await _secureStorage.read(key: 'access_token');
    // tmp (early dev)
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt');
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: 'access_token');
  }

  Future<void> saveUser(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', user.name);
    await prefs.setString('email', user.email);
    await prefs.setString('picture', user.picture);
    await prefs.setString('id', user.id);
    await prefs.setString('createdAt', user.createdAt.toIso8601String());
    await prefs.setString('jwt', user.jwt);
  }

  Future<AuthUser?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    final email = prefs.getString('email');
    final picture = prefs.getString('picture');
    final id = prefs.getString('id');
    final createdAt = prefs.getString('createdAt');
    final jwt = prefs.getString('jwt');

    if (name != null && email != null) {
      return AuthUser(
        id: id ?? '',
        name: name,
        email: email,
        picture: picture ?? '',
        jwt: jwt ?? '',
        createdAt: createdAt != null
            ? DateTime.parse(createdAt)
            : DateTime.now(),
      );
    }
    return null;
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('name');
    await prefs.remove('email');
    await prefs.remove('picture');
    await prefs.remove('id');
    await prefs.remove('createdAt');
    await prefs.remove('jwt');
  }

  Future<void> clearAll() async {
    await clearToken();
    await clearUser();
  }
}
