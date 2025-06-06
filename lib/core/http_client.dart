import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class HttpClientWrapper {
  final _secureStorage = const FlutterSecureStorage();
  final http.Client _client;

  HttpClientWrapper(this._client);

  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final token = await _secureStorage.read(key: 'access_token');
    final updatedHeaders = {...?headers, 'Authorization': 'Bearer $token'};

    return _client.post(
      url,
      headers: updatedHeaders,
      body: body,
      encoding: encoding,
    );
  }

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final token = await _secureStorage.read(key: 'access_token');
    final updatedHeaders = {...?headers, 'Authorization': 'Bearer $token'};

    return _client.get(url, headers: updatedHeaders);
  }

  // Add other HTTP methods (put, delete, etc.) as needed
}
