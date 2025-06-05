import 'dart:convert';
import 'dart:io';
import 'package:ai_voice_note/constant/env.dart';
import 'package:ai_voice_note/features/auth/domain/auth_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

final authServiceProvider = Provider<AuthService>((_) => AuthService());

class AuthService {
  final clientId = GOOGLE_CLIENT_ID;
  final portNumber = 8080;
  String get redirectUri => "http://localhost:$portNumber";
  final scope = 'openid email profile';

  Future<AuthUser?> signInWithGoogle() async {
    final authUrl = Uri.parse(
      'https://accounts.google.com/o/oauth2/v2/auth'
      '?response_type=code'
      '&client_id=$clientId'
      '&redirect_uri=$redirectUri'
      '&scope=$scope',
    );

    // Launch browser for user to sign in
    await launchUrl(authUrl);

    // Start a temporary local server to catch redirect
    final server = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      portNumber,
    );
    final request = await server.first;
    final queryParams = request.uri.queryParameters;

    print('🔗 Redirected with query params: $queryParams');

    // Respond to the browser so user sees a "success" message
    request.response
      ..statusCode = 200
      ..headers.set('Content-Type', 'text/html')
      ..write('<h3>You can now return to the app.</h3>')
      ..close();

    server.close();

    final code = queryParams['code'];
    if (code == null) {
      print('❌ Authorization code missing');
      return null;
    }

    // pass code to api server in exchange for jwtToken + user data
    // do something

    return null;
  }
}
