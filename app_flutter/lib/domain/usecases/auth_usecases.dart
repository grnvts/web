import '../repositories/auth_repository.dart';

class AuthUseCases {
  final AuthRepository _repository;

  const AuthUseCases(this._repository);

  Future<Map<String, dynamic>> login(
    String username,
    String password, {
    String? captchaValue,
  }) =>
      _repository.login(
        username,
        password,
        captchaValue: captchaValue,
      );

  Future<Map<String, dynamic>> signup(Map<String, dynamic> userData) =>
      _repository.signup(userData);

  Future<void> logout() => _repository.logout();

  Future<String?> getToken() => _repository.getToken();

  Future<String?> getUsername() => _repository.getUsername();

  Future<bool> isAuthenticated() => _repository.isAuthenticated();

  Future<bool> isAdmin() => _repository.isAdmin();

  Future<bool> isBrigadier() => _repository.isBrigadier();

  Future<bool> isUser() => _repository.isUser();

  Future<String> primaryRoleLabel() => _repository.primaryRoleLabel();
}
