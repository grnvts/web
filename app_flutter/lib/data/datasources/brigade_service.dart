import 'dart:convert';

import '../../domain/repositories/auth_repository.dart';
import 'api_client.dart';

class BrigadeService {
  final ApiClient _client;

  BrigadeService(AuthRepository authRepository)
      : _client = ApiClient(authRepository);

  Future<List<dynamic>> getAllBrigades() async => _getList('/brigade/all');
  Future<List<dynamic>> getAllMasters() async => _getList('/user/masters');
  Future<List<dynamic>> getMyBrigadeMasters() async =>
      _getList('/brigade/my/masters');
  Future<List<dynamic>> getBrigadeMasters(int brigadeId) async =>
      _getList('/orders/brigade/$brigadeId/masters');

  Future<void> addMasterToBrigade(int brigadeId, int userId) async =>
      _postWithoutResult('/brigade/$brigadeId/add-master', {'userId': userId});
  Future<void> removeMasterFromBrigade(int brigadeId, int userId) async =>
      _postWithoutResult('/brigade/$brigadeId/remove-master', {
        'userId': userId,
      });
  Future<void> addMasterToMyBrigade(int userId) async =>
      _postWithoutResult('/brigade/my/add-master', {'userId': userId});
  Future<void> removeMasterFromMyBrigade(int userId) async =>
      _postWithoutResult('/brigade/my/remove-master', {'userId': userId});

  Future<List<dynamic>> _getList(String path) async {
    final response = await _client.get(path);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded is List ? decoded : <dynamic>[];
    }
    throw Exception('Failed to load brigade data');
  }

  Future<void> _postWithoutResult(
    String path,
    Map<String, dynamic> payload,
  ) async {
    final response = await _client.post(path, body: payload);
    if (response.statusCode != 200) {
      throw Exception('Failed to update brigade');
    }
  }
}
