import 'dart:convert';

import '../../domain/repositories/auth_repository.dart';
import 'api_client.dart';

class UserService {
  final ApiClient _client;

  UserService(AuthRepository authRepository)
      : _client = ApiClient(authRepository);

  Future<Map<String, dynamic>> getUsers(int page, int size) async {
    final response = await _client.get('/user/users?page=$page&size=$size');
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception(_extractError(response, 'Failed to load users'));
  }

  Future<Map<String, dynamic>> getUserByUsername(String username) async {
    final response = await _client.get('/user/$username');
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception(_extractError(response, 'User not found'));
  }

  Future<Map<String, dynamic>> updateUser(
    String username,
    Map<String, dynamic> payload,
  ) async {
    final response = await _client.put('/user/$username', body: payload);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception(_extractError(response, 'Failed to update user'));
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> payload) async {
    final response = await _client.post('/user/create', body: payload);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception(_extractError(response, 'Failed to create user'));
  }

  Future<Map<String, dynamic>> createMaster(
    Map<String, dynamic> payload,
  ) async {
    final response = await _client.post('/user/masters', body: payload);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception(_extractError(response, 'Failed to create master'));
  }

  Future<List<dynamic>> getQualifications() async {
    final response = await _client.get('/user/qualifications');
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded is List ? decoded : <dynamic>[];
    }
    throw Exception(_extractError(response, 'Failed to load qualifications'));
  }

  Future<List<dynamic>> getAdmins() async {
    final response = await _client.get('/user/admins');
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded is List ? decoded : <dynamic>[];
    }
    throw Exception(_extractError(response, 'Failed to load admins'));
  }

  Future<Map<String, dynamic>> uploadImage(
    String username,
    String imageBase64,
  ) async {
    final response = await _client.put(
      '/user/upload-image/$username',
      body: <String, dynamic>{'image': imageBase64},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception(_extractError(response, 'Failed to upload image'));
  }

  Future<void> deleteUser(int id) async {
    final response = await _client.delete('/user/$id');
    if (response.statusCode != 200) {
      throw Exception(_extractError(response, 'Failed to delete user'));
    }
  }

  Future<void> restoreUser(int id) async {
    final response = await _client.put('/user/$id/restore');
    if (response.statusCode != 200) {
      throw Exception(_extractError(response, 'Failed to restore user'));
    }
  }

  String _extractError(dynamic response, String fallback) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        if (decoded['message'] != null) return decoded['message'].toString();
        if (decoded['error'] != null) return decoded['error'].toString();
      }
      if (decoded is String && decoded.isNotEmpty) {
        return decoded;
      }
    } catch (_) {
      // ignore
    }
    return fallback;
  }
}
