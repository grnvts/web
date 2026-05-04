import 'dart:convert';

import '../../domain/repositories/auth_repository.dart';
import 'api_client.dart';

class OrderService {
  final ApiClient _client;

  OrderService(AuthRepository authRepository)
      : _client = ApiClient(authRepository);

  Future<List<dynamic>> getAllOrders() async => _getList('/orders');
  Future<List<dynamic>> getMyOrders() async => _getList('/orders/my');
  Future<List<dynamic>> getActiveOrdersForBrigadier() async =>
      _getList('/orders/brigadier/active');
  Future<List<dynamic>> getAssignedMasters(int orderId) async =>
      _getList('/orders/$orderId/assigned-masters');
  Future<List<dynamic>> getAllBrigadiers() async =>
      _getList('/orders/brigadiers');

  Future<Map<String, dynamic>> getOrderById(int orderId) async {
    final response = await _client.get('/orders/$orderId');
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Order not found');
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> payload) async {
    final response = await _client.post('/orders', body: payload);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception(_extractError(response, 'Failed to create order'));
  }

  Future<void> updateOrder(int orderId, Map<String, dynamic> payload) async {
    final response = await _client.put('/orders/$orderId', body: payload);
    if (response.statusCode != 200) {
      throw Exception(_extractError(response, 'Failed to update order'));
    }
  }

  Future<void> assignBrigadier(int orderId, String username) async {
    final response = await _client.put(
      '/orders/$orderId/assign-brigadier',
      body: {'username': username},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to assign brigadier');
    }
  }

  Future<void> updateOrderStatus(
    int orderId,
    String status, {
    String? message,
  }) async {
    final response = await _client.put(
      '/orders/$orderId/status',
      body: {'status': status, 'message': message},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update status');
    }
  }

  Future<void> assignMasters(int orderId, List<int> masterIds) async {
    final response = await _client.put(
      '/orders/$orderId/assign-masters',
      body: masterIds,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to assign masters');
    }
  }

  Future<Map<String, dynamic>> addExpense(int orderId, double amount) async {
    final response = await _client.post(
      '/orders/$orderId/add-expense',
      body: {'amount': amount},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception(_extractError(response, 'Failed to add expense'));
  }

  Future<List<dynamic>> _getList(String path) async {
    final response = await _client.get(path);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded is List ? decoded : <dynamic>[];
    }
    throw Exception(_extractError(response, 'Failed to load data'));
  }

  String _extractError(dynamic response, String fallback) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        if (decoded['message'] != null) return decoded['message'].toString();
        if (decoded['error'] != null) return decoded['error'].toString();
      }
    } catch (_) {
      // ignore
    }
    return fallback;
  }
}
