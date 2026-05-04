import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';

class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(
    String username,
    String password, {
    String? captchaValue,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/login'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'captchaValue': captchaValue,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractError(response, fallback: 'Login failed'));
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> signup(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/user'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(_extractError(response, fallback: 'Signup failed'));
  }

  String _extractError(http.Response response, {required String fallback}) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        if (decoded['message'] != null) return decoded['message'].toString();
        if (decoded['error'] != null) return decoded['error'].toString();
      }
    } catch (_) {
      // ignore
    }
    if (response.statusCode == 401 || response.statusCode == 403) {
      return 'Invalid username or password';
    }
    return fallback;
  }
}
