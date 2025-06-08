import 'dart:convert';

import 'package:ai_voice_note/features/auth/shared/auth_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class HttpClientWrapper {
  final http.Client _client;
  final AuthStorage _authStorage = AuthStorage();

  HttpClientWrapper(this._client);

  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final userData = await AuthStorage().getUser();
    if (userData?.jwt == null) {
      throw Exception('User JWT token is null');
    }

    // debug
    // print('User JWT: ${userData?.jwt}');

    final updatedHeaders = {
      ...?headers,
      'Authorization': 'Bearer ${userData?.jwt}',
    };

    return _client.post(
      url,
      headers: updatedHeaders,
      body: body,
      encoding: encoding,
    );
  }

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    // final token = await _secureStorage.read(key: 'access_token');
    final userData = await AuthStorage().getUser();
    if (userData?.jwt == null) {
      throw Exception('User JWT token is null');
    }

    final updatedHeaders = {
      ...?headers,
      'Authorization': 'Bearer ${userData?.jwt}',
    };

    return _client.get(url, headers: updatedHeaders);
  }

  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final userData = await AuthStorage().getUser();
    if (userData?.jwt == null) {
      throw Exception('User JWT token is null');
    }

    final updatedHeaders = {
      ...?headers,
      'Authorization': 'Bearer ${userData?.jwt}',
    };

    return _client.put(
      url,
      headers: updatedHeaders,
      body: body,
      encoding: encoding,
    );
  }

  // Add other HTTP methods (delete, etc.) as needed
}
