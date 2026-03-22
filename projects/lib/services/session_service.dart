import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../models/auth.dart';
import '../models/user.dart';

class SessionService {
  Future<void> saveAuthSession(AuthResponse auth) async {
    final prefs = await SharedPreferences.getInstance();
    if (auth.accessToken != null) {
      await prefs.setString(StorageKeys.accessToken, auth.accessToken!);
    }
    if (auth.refreshToken != null) {
      await prefs.setString(StorageKeys.refreshToken, auth.refreshToken!);
    }
    if (auth.user != null) {
      await _saveUserData(prefs, auth.user!);
    }
  }

  Future<void> _saveUserData(SharedPreferences prefs, UserResponse user) async {
    await prefs.setInt(StorageKeys.userId, user.id);
    await prefs.setString(StorageKeys.fullName, user.fullName);
    await prefs.setString(StorageKeys.email, user.email);
    await prefs.setString(StorageKeys.username, user.username);
    if (user.phone != null) {
      await prefs.setString(StorageKeys.phone, user.phone!);
    }
    await prefs.setStringList(StorageKeys.roles, user.roles.toList());
  }

  Future<void> saveUserResponse(UserResponse user) async {
    final prefs = await SharedPreferences.getInstance();
    await _saveUserData(prefs, user);
  }

  Future<void> saveClassInfo(int classId, String className) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(StorageKeys.classId, classId);
    await prefs.setString(StorageKeys.className, className);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageKeys.accessToken);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageKeys.refreshToken);
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(StorageKeys.userId);
  }

  Future<String?> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageKeys.fullName);
  }

  Future<List<String>> getRoles() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(StorageKeys.roles) ?? [];
  }

  Future<int?> getClassId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(StorageKeys.classId);
  }

  Future<String?> getClassName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageKeys.className);
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> hasRole(String role) async {
    final roles = await getRoles();
    return roles.contains(role);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.accessToken);
    await prefs.remove(StorageKeys.refreshToken);
    await prefs.remove(StorageKeys.userId);
    await prefs.remove(StorageKeys.roles);
    await prefs.remove(StorageKeys.fullName);
    await prefs.remove(StorageKeys.email);
    await prefs.remove(StorageKeys.phone);
    await prefs.remove(StorageKeys.username);
    await prefs.remove(StorageKeys.classId);
    await prefs.remove(StorageKeys.className);
  }
}

// Extension on SharedPreferences to handle int with StorageKeys as String
extension SharedPreferencesExt on SharedPreferences {
  Future<bool> setInt(String key, int value) {
    return setString(key, value.toString());
  }

  int? getInt(String key) {
    final val = getString(key);
    return val != null ? int.tryParse(val) : null;
  }
}