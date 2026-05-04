import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../domain/repositories/auth_repository.dart';

class ApiClient {
  final AuthRepository _authRepository;

  const ApiClient(this._authRepository);

  Uri _uri(String path) => Uri.parse('${AppConfig.apiBaseUrl}$path');

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      final token = await _authRepository.getToken();
      headers['Authorization'] = 'Bearer ${token ?? ''}';
    }
    return headers;
  }

  Future<http.Response> get(String path, {bool auth = true}) async {
    return http.get(_uri(path), headers: await _headers(auth: auth));
  }

  Future<http.Response> post(
    String path, {
    Object? body,
    bool auth = true,
  }) async {
    return http.post(
      _uri(path),
      headers: await _headers(auth: auth),
      body: body == null ? null : jsonEncode(body),
    );
  }

  Future<http.Response> put(
    String path, {
    Object? body,
    bool auth = true,
  }) async {
    return http.put(
      _uri(path),
      headers: await _headers(auth: auth),
      body: body == null ? null : jsonEncode(body),
    );
  }

  Future<http.Response> delete(String path, {bool auth = true}) async {
    return http.delete(_uri(path), headers: await _headers(auth: auth));
  }
}
