abstract class UserRepository {
  Future<Map<String, dynamic>> getUsers(int page, int size);

  Future<Map<String, dynamic>> getUserByUsername(String username);

  Future<Map<String, dynamic>> updateUser(
    String username,
    Map<String, dynamic> payload,
  );

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> payload);

  Future<Map<String, dynamic>> createMaster(Map<String, dynamic> payload);

  Future<List<dynamic>> getQualifications();

  Future<List<dynamic>> getAdmins();

  Future<Map<String, dynamic>> uploadImage(
    String username,
    String imageBase64,
  );

  Future<void> deleteUser(int id);

  Future<void> restoreUser(int id);
}
