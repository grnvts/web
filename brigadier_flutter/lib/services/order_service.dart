import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class OrderService {
  static const String baseUrl = 'http://10.178.229.40:8501/api';
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  Future<List<dynamic>> getActiveOrdersForBrigadier() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/orders/brigadier/active'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Ошибка загрузки заказов: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getOrderById(int orderId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Ошибка загрузки заказа: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка: ${e.toString()}');
    }
  }

  Future<void> updateOrderStatus(int orderId, String status, {String? message}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/orders/$orderId/status'),
        headers: headers,
        body: jsonEncode({
          'status': status,
          'message': message,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка обновления статуса: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка: ${e.toString()}');
    }
  }

  Future<List<dynamic>> getAssignedMasters(int orderId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$orderId/assigned-masters'),
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

  Future<void> assignMasters(int orderId, List<int> masterIds) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/orders/$orderId/assign-masters'),
        headers: headers,
        body: jsonEncode(masterIds),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка назначения мастеров: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка: ${e.toString()}');
    }
  }

  // Методы для обычных пользователей
  Future<List<dynamic>> getMyOrders() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/orders/my'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Ошибка загрузки заказов: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: headers,
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final errorBody = response.body;
        try {
          final error = jsonDecode(errorBody);
          final errorMessage = error['message'] ?? error['error'] ?? '';
          throw Exception(errorMessage.isNotEmpty ? errorMessage : 'Ошибка создания заказа');
        } catch (e) {
          throw Exception('Ошибка создания заказа: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Ошибка: ${e.toString()}');
    }
  }
}

