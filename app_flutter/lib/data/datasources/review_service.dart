import 'dart:convert';

import '../../domain/repositories/auth_repository.dart';
import 'api_client.dart';

class ReviewService {
  final ApiClient _client;

  ReviewService(AuthRepository authRepository)
      : _client = ApiClient(authRepository);

  Future<List<dynamic>> getOrderReviews(int orderId) async {
    final response = await _client.get('/reviews/orders/$orderId');
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded is List ? decoded : <dynamic>[];
    }
    throw Exception(_extractError(response, 'Failed to load reviews'));
  }

  Future<List<dynamic>> getRatingCategories() async {
    final response = await _client.get('/reviews/categories');
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded is List ? decoded : <dynamic>[];
    }
    throw Exception(
      _extractError(response, 'Failed to load review categories'),
    );
  }

  Future<Map<String, dynamic>> createReview(
    int orderId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _client.post('/reviews/orders/$orderId', body: payload);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception(_extractError(response, 'Failed to create review'));
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
