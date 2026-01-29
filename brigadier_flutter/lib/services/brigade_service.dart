import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class BrigadeService {
  static const String baseUrl = 'http://10.178.229.40:8501/api';
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  Future<List<dynamic>> getMyBrigadeMasters() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/brigade/my/masters'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Ошибка загрузки мастеров: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка: ${e.toString()}');
    }
  }

  Future<List<dynamic>> getAllMasters() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/user/masters'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Ошибка загрузки мастеров: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка: ${e.toString()}');
    }
  }

  Future<void> addMasterToMyBrigade(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/brigade/my/add-master'),
        headers: headers,
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка добавления мастера: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка: ${e.toString()}');
    }
  }

  Future<void> removeMasterFromMyBrigade(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/brigade/my/remove-master'),
        headers: headers,
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка удаления мастера: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка: ${e.toString()}');
    }
  }
}

