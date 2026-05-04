abstract class AuthRepository {
  Future<Map<String, dynamic>> login(
    String username,
    String password, {
    String? captchaValue,
  });

  Future<Map<String, dynamic>> signup(Map<String, dynamic> userData);

  Future<void> logout();

  Future<String?> getToken();

  Future<String?> getUsername();

  Future<bool> isAuthenticated();

  Future<bool> isAdmin();

  Future<bool> isBrigadier();

  Future<bool> isUser();

  Future<String> primaryRoleLabel();
}
