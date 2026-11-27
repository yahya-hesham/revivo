import 'package:dio/dio.dart';
import '../../../../core/services/apis/api_error.dart';
import '../../../../core/services/apis/apis.dart';
import '../../../../core/services/apis/dio_provider.dart';
import '../../../../core/services/local/shared_pref.dart';
import '../models/auth_request_models.dart';
import '../models/user_model.dart';

/// Auth API repository covering `/api/auth/register`, `/login`, and `/me`.
abstract final class AuthRepo {
  /// Registers a new user and returns the created user's GUID `id`.
  /// Note: the backend returns no JWT on register; the user signs in next.
  static Future<String> register(RegisterRequestModel request) async {
    try {
      final response = await DioProvider.post(
        endpoint: Apis.register,
        data: request.toJson(),
      );
      if (response.statusCode == 201 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        return (data['id'] ?? data['Id'] ?? '').toString();
      }
      throw const ApiException(message: 'Failed to create account.');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Signs in, saves the JWT securely, fetches `/api/auth/me`, and caches the user.
  static Future<UserModel> login(LoginRequestModel request) async {
    try {
      final response = await DioProvider.post(
        endpoint: Apis.login,
        data: request.toJson(),
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final token =
            (data['accessToken'] ?? data['AccessToken'] ?? '').toString();
        if (token.isEmpty) {
          throw const ApiException(message: 'Invalid login response.');
        }
        await SharedPref.saveToken(token);
        final user = await fetchCurrentUser();
        await SharedPref.saveUserMap(user.toJson());
        return user;
      }
      throw const ApiException(message: 'Failed to sign in.');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  static Future<UserModel> fetchCurrentUser() async {
    try {
      final response = await DioProvider.get(endpoint: Apis.me);
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ApiException(message: 'Failed to load user profile.');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  static Future<void> logout() => SharedPref.clearSession();
}
