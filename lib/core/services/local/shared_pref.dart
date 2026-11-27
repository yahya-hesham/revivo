import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'secure_storage.dart';

/// Centralized local persistence wrapper.
/// Non-sensitive preferences live in [SharedPreferences]; the JWT access token
/// is stored in [SecureStorage] (OS keychain / encrypted keystore) and cached
/// in memory after [init] for synchronous access.
abstract final class SharedPref {
  static late SharedPreferences _prefs;
  static String _cachedToken = '';

  static const String kUserJson = 'revivo_user_json';
  static const String kThemeMode = 'revivo_theme_mode';
  static const String kLocaleCode = 'revivo_locale_code';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _cachedToken = (await SecureStorage.getToken()) ?? '';
  }

  static bool get isLoggedIn => _cachedToken.isNotEmpty;

  static String getToken() => _cachedToken;

  static Future<void> saveToken(String token) async {
    _cachedToken = token;
    await SecureStorage.saveToken(token);
  }

  static Future<void> clearSession() async {
    _cachedToken = '';
    await SecureStorage.deleteToken();
    await _prefs.remove(kUserJson);
  }

  static Future<void> saveUserMap(Map<String, dynamic> user) async {
    await _prefs.setString(kUserJson, jsonEncode(user));
  }

  static Map<String, dynamic>? getUserMap() {
    final raw = _prefs.getString(kUserJson);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  static String? getString(String key) => _prefs.getString(key);

  static Future<void> setBool(String key, bool value) =>
      _prefs.setBool(key, value);

  static bool? getBool(String key) => _prefs.getBool(key);

  static Future<void> remove(String key) => _prefs.remove(key);
}
