import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../infrastructure/auth_service.dart';
import '../domain/auth_user.dart';
import '../shared/auth_storage.dart';

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(
    authService: ref.read(authServiceProvider),
    authStorage: AuthStorage(),
  );
});

class AuthController {
  final AuthService authService;
  final AuthStorage authStorage;

  AuthController({required this.authService, required this.authStorage});

  Future<AuthUser?> signInWithGoogle() async {
    try {
      final user = await authService.signInWithGoogle();
      if (user != null) {
        // await authStorage.saveToken(user.jwt); // tmp commented out till ready
        await authStorage.saveUser(user);
      }
      return user;
    } catch (e) {
      print('❌ Sign in failed: $e');
      return null;
    }
  }

  Future<String?> getAccessToken() => authStorage.getToken();

  Future<AuthUser?> getCurrentUser() => authStorage.getUser();

  Future<void> signOut() => authStorage.clearAll();
}
