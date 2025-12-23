import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://172.26.205.54:8501/api';

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'captchaValue': null,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['jwttoken'];
        final user = data;

        final roles = user['roles'] as List<dynamic>? ?? [];
        final isBrigadier = roles.contains('ROLE_BRIGADIER');
        final isUser = roles.contains('ROLE_USER');

        if (!isBrigadier && !isUser) {
          throw Exception('Доступ разрешен только бригадирам и пользователям');
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setBool('is_brigadier', isBrigadier);
        await prefs.setBool('is_user', isUser);
        await prefs.setString('username', user['username']);

        return {
          'success': true,
          'token': token,
          'user': user,
        };
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Неверные учетные данные
        throw Exception('Неверный логин и пароль');
      } else {
        final errorBody = response.body;
        try {
          final error = jsonDecode(errorBody);
          final errorMessage = error['message'] ?? error['error'] ?? '';
          
          // Проверяем, является ли ошибка связанной с неправильными учетными данными
          if (errorMessage.toLowerCase().contains('bad credentials') ||
              errorMessage.toLowerCase().contains('invalid') ||
              errorMessage.toLowerCase().contains('unauthorized') ||
              errorMessage.toLowerCase().contains('неверный') ||
              errorMessage.toLowerCase().contains('неправильный')) {
            throw Exception('Неверный логин и пароль');
          }
          
          throw Exception(errorMessage.isNotEmpty ? errorMessage : 'Ошибка входа');
        } catch (e) {
          if (e.toString().contains('Неверный логин и пароль')) {
            rethrow;
          }
          throw Exception('Ошибка входа: ${response.statusCode}');
        }
      }
    } catch (e) {
      // Если это уже наше сообщение об ошибке, просто пробрасываем его
      if (e.toString().contains('Неверный логин и пароль') ||
          e.toString().contains('Доступ разрешен')) {
        rethrow;
      }
      
      // Проверяем, не связана ли ошибка с неправильными учетными данными
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('bad credentials') ||
          errorString.contains('unauthorized') ||
          errorString.contains('401') ||
          errorString.contains('403')) {
        throw Exception('Неверный логин и пароль');
      }
      
      // Для других ошибок (например, сетевых) оставляем оригинальное сообщение
      throw Exception(e.toString());
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('is_brigadier');
    await prefs.remove('is_user');
    await prefs.remove('username');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<bool> isBrigadier() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_brigadier') ?? false;
  }

  Future<bool> isUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_user') ?? false;
  }

  Future<Map<String, dynamic>> signup(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'user': data,
        };
      } else {
        final errorBody = response.body;
        try {
          final error = jsonDecode(errorBody);
          final errorMessage = error['message'] ?? error['error'] ?? '';
          if (error['validationErrors'] != null) {
            throw Exception(error['validationErrors'].toString());
          }
          throw Exception(errorMessage.isNotEmpty ? errorMessage : 'Ошибка регистрации');
        } catch (e) {
          if (e.toString().contains('validationErrors') || e.toString().contains('Ошибка регистрации')) {
            rethrow;
          }
          throw Exception('Ошибка регистрации: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

