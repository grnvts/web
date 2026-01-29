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
  
  Future<List<dynamic>> getAllOrders() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List ? data : [];
      } else {
        throw Exception('Ошибка загрузки заказов');
      }
    } catch (e) {
      throw Exception(e.toString());
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
        return jsonDecode(response.body);
      } else {
        throw Exception('Заказ не найден');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  
  Future<Map<String, dynamic>> updateOrder(int orderId, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: headers,
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Ошибка обновления заказа');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  
  Future<void> updateOrderStatus(int orderId, String status) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/orders/$orderId/status'),
        headers: headers,
        body: jsonEncode({'status': status}),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Ошибка обновления статуса заказа');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  
  Future<void> assignBrigadier(int orderId, String brigadierUsername) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/orders/$orderId/assign-brigadier'),
        headers: headers,
        body: jsonEncode({'username': brigadierUsername}),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Ошибка назначения бригадира');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  
  Future<List<dynamic>> getAllBrigadiers() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/orders/brigadiers'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List ? data : [];
      } else {
        throw Exception('Ошибка загрузки бригадиров');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
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
}

