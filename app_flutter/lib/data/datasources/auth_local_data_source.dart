import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  static const _tokenKey = 'jwt_token';
  static const _usernameKey = 'username';
  static const _isAdminKey = 'is_admin';
  static const _isBrigadierKey = 'is_brigadier';
  static const _isUserKey = 'is_user';

  Future<void> saveSession({
    required String token,
    required String username,
    required List<String> roles,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_usernameKey, username);
    await prefs.setBool(_isAdminKey, roles.contains('ROLE_ADMIN'));
    await prefs.setBool(_isBrigadierKey, roles.contains('ROLE_BRIGADIER'));
    await prefs.setBool(_isUserKey, roles.contains('ROLE_USER'));
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_isAdminKey);
    await prefs.remove(_isBrigadierKey);
    await prefs.remove(_isUserKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  Future<bool> isAuthenticated() async =>
      (await getToken())?.isNotEmpty == true;

  Future<bool> isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isAdminKey) ?? false;
  }

  Future<bool> isBrigadier() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isBrigadierKey) ?? false;
  }

  Future<bool> isUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isUserKey) ?? false;
  }

  Future<String> primaryRoleLabel() async {
    if (await isAdmin()) return 'Admin';
    if (await isBrigadier()) return 'Brigadier';
    if (await isUser()) return 'User';
    return 'Guest';
  }
}
