import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  const AuthRepositoryImpl(this._remote, this._local);

  @override
  Future<Map<String, dynamic>> login(
    String username,
    String password, {
    String? captchaValue,
  }) async {
    final data = await _remote.login(
      username,
      password,
      captchaValue: captchaValue,
    );

    final token = (data['jwttoken'] ?? data['token'])?.toString();
    if (token == null || token.isEmpty) {
      throw Exception('Server did not return a JWT token');
    }

    final roles = ((data['roles'] as List?) ?? const <dynamic>[])
        .map((role) => role.toString())
        .toList(growable: false);
    final resolvedUsername = (data['username'] ?? username).toString();

    await _local.saveSession(
      token: token,
      username: resolvedUsername,
      roles: roles,
    );

    return data;
  }

  @override
  Future<Map<String, dynamic>> signup(Map<String, dynamic> userData) =>
      _remote.signup(userData);

  @override
  Future<void> logout() => _local.clearSession();

  @override
  Future<String?> getToken() => _local.getToken();

  @override
  Future<String?> getUsername() => _local.getUsername();

  @override
  Future<bool> isAuthenticated() => _local.isAuthenticated();

  @override
  Future<bool> isAdmin() => _local.isAdmin();

  @override
  Future<bool> isBrigadier() => _local.isBrigadier();

  @override
  Future<bool> isUser() => _local.isUser();

  @override
  Future<String> primaryRoleLabel() => _local.primaryRoleLabel();
}
