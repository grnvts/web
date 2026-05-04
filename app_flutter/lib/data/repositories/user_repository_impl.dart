import '../../domain/repositories/user_repository.dart';
import '../datasources/user_service.dart';

class UserRepositoryImpl implements UserRepository {
  final UserService _dataSource;

  const UserRepositoryImpl(this._dataSource);

  @override
  Future<Map<String, dynamic>> getUsers(int page, int size) =>
      _dataSource.getUsers(page, size);

  @override
  Future<Map<String, dynamic>> getUserByUsername(String username) =>
      _dataSource.getUserByUsername(username);

  @override
  Future<Map<String, dynamic>> updateUser(
    String username,
    Map<String, dynamic> payload,
  ) =>
      _dataSource.updateUser(username, payload);

  @override
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> payload) =>
      _dataSource.createUser(payload);

  @override
  Future<Map<String, dynamic>> createMaster(Map<String, dynamic> payload) =>
      _dataSource.createMaster(payload);

  @override
  Future<List<dynamic>> getQualifications() => _dataSource.getQualifications();

  @override
  Future<List<dynamic>> getAdmins() => _dataSource.getAdmins();

  @override
  Future<Map<String, dynamic>> uploadImage(
    String username,
    String imageBase64,
  ) =>
      _dataSource.uploadImage(username, imageBase64);

  @override
  Future<void> deleteUser(int id) => _dataSource.deleteUser(id);

  @override
  Future<void> restoreUser(int id) => _dataSource.restoreUser(id);
}
