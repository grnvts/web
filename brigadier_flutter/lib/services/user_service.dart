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
        final errorBody = response.body;
        try {
          final error = jsonDecode(errorBody);
          throw Exception(error['message'] ?? 'Ошибка обновления пользователя');
        } catch (e) {
          throw Exception('Ошибка обновления пользователя: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> uploadImage(String username, String base64Image) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/user/upload-image/$username'),
        headers: headers,
        body: jsonEncode({'image': base64Image}),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = response.body;
        try {
          final error = jsonDecode(errorBody);
          throw Exception(error['message'] ?? 'Ошибка загрузки изображения');
        } catch (e) {
          throw Exception('Ошибка загрузки изображения: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

