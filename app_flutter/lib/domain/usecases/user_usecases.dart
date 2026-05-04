import '../repositories/user_repository.dart';

class UserUseCases {
  final UserRepository _repository;

  const UserUseCases(this._repository);

  Future<Map<String, dynamic>> getUsers(int page, int size) =>
      _repository.getUsers(page, size);

  Future<Map<String, dynamic>> getUserByUsername(String username) =>
      _repository.getUserByUsername(username);

  Future<Map<String, dynamic>> updateUser(
    String username,
    Map<String, dynamic> payload,
  ) =>
      _repository.updateUser(username, payload);

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> payload) =>
      _repository.createUser(payload);

  Future<Map<String, dynamic>> createMaster(Map<String, dynamic> payload) =>
      _repository.createMaster(payload);

  Future<List<dynamic>> getQualifications() => _repository.getQualifications();

  Future<List<dynamic>> getAdmins() => _repository.getAdmins();

  Future<Map<String, dynamic>> uploadImage(
    String username,
    String imageBase64,
  ) =>
      _repository.uploadImage(username, imageBase64);

  Future<void> deleteUser(int id) => _repository.deleteUser(id);

  Future<void> restoreUser(int id) => _repository.restoreUser(id);
}
