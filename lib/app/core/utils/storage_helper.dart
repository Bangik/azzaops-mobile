import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import '../../data/models/user_model.dart';

class StorageHelper {
  static final _box = GetStorage();

  static const _keyToken = 'token';
  static const _keyUserRole = 'user_role';
  static const _keyUserData = 'user_data';

  static Future<void> init() async {
    await GetStorage.init();
  }

  static Future<void> saveToken(String token) async {
    await _box.write(_keyToken, token);
  }

  static String? getToken() {
    return _box.read<String>(_keyToken);
  }

  static Future<void> clearToken() async {
    await _box.remove(_keyToken);
  }

  static Future<void> saveUserRole(String role) async {
    await _box.write(_keyUserRole, role);
  }

  static String? getUserRole() {
    return _box.read<String>(_keyUserRole);
  }

  static Future<void> saveUserData(UserModel user) async {
    await _box.write(_keyUserData, jsonEncode(user.toJson()));
    await saveUserRole(user.role);
  }

  static UserModel? getUserData() {
    final data = _box.read<String>(_keyUserData);
    if (data == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(data) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearAll() async {
    await _box.erase();
  }
}
