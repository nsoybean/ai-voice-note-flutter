import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../infrastructure/auth_service.dart';
import '../domain/auth_user.dart';

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref.read(authServiceProvider));
});

class AuthController {
  final AuthService _authService;

  AuthController(this._authService);

  Future<AuthUser?> signInWithGoogle() async {
    try {
      return await _authService.signInWithGoogle();
    } catch (_) {
      return null;
    }
  }
}
