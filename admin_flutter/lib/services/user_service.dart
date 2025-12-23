import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class UserService {
  static const String baseUrl = 'http://172.26.205.54:8501/api';
  final AuthService _authService = AuthService();
  
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }
  
  Future<Map<String, dynamic>> getUsers(int page, int size) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/user/users?page=$page&size=$size'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Ошибка загрузки пользователей');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  
  Future<Map<String, dynamic>> getUserByUsername(String username) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/user/$username'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Пользователь не найден');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  
  Future<Map<String, dynamic>> updateUser(String username, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/user/$username'),
        headers: headers,
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Ошибка обновления пользователя');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/user/create'),
        headers: headers,
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Ошибка создания пользователя');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  
  Future<void> deleteUser(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/user/$userId'),
        headers: headers,
      );
      
      if (response.statusCode != 200) {
        throw Exception('Ошибка удаления пользователя');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  
  Future<void> restoreUser(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/user/$userId/restore'),
        headers: headers,
      );
      
      if (response.statusCode != 200) {
        throw Exception('Ошибка восстановления пользователя');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}


