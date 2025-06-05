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
      ..write('''
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>Login Successful</title>
    <style>
      body {
        margin: 0;
        height: 100vh;
        font-family: 'Inter', sans-serif;
        background: linear-gradient(135deg, #F9FAFB 0%, #EDF0FF 100%);
        color: #111827;
        display: flex;
        justify-content: center;
        align-items: center;
      }

      .notice {
        background: white;
        padding: 32px 40px;
        border-radius: 12px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        text-align: center;
        max-width: 420px;
      }

      .notice h1 {
        font-size: 24px;
        font-weight: 700;
        margin-bottom: 12px;
        background: linear-gradient(to right, #4A6CF7, #758DFF);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
      }

      .notice p {
        font-size: 16px;
        color: #6B7280;
        margin-top: 0;
      }
    </style>
  </head>
  <body>
    <div class="notice">
      <h1>You're logged in</h1>
      <p>You may now return to the AI Voice Note app.</p>
    </div>
  </body>
</html>
''')
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
