import 'package:dio/dio.dart';
import '../../../../core/services/apis/api_error.dart';
import '../../../../core/services/apis/apis.dart';
import '../../../../core/services/apis/dio_provider.dart';
import '../models/user_model.dart';

/// Auth API repository.
/// Currently implements `/api/auth/me` for Splash session bootstrap;
/// login/register will be added in Milestone 2.
abstract final class AuthRepo {
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
}
