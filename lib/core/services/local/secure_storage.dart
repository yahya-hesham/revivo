import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure key-value storage for sensitive credentials (JWT access token).
abstract final class SecureStorage {
  static const String _kAccessToken = 'revivo_access_token';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<void> saveToken(String token) =>
      _storage.write(key: _kAccessToken, value: token);

  static Future<String?> getToken() => _storage.read(key: _kAccessToken);

  static Future<void> deleteToken() => _storage.delete(key: _kAccessToken);
}
