import 'package:dio/dio.dart';
import '../local/shared_pref.dart';
import 'apis.dart';

/// Centralized static Dio HTTP client wrapper.
/// Automatically attaches `Authorization: Bearer <token>` and handles 401
/// responses by clearing the local session and triggering [onUnauthorized].
abstract final class DioProvider {
  static late Dio dio;

  /// Optional callback invoked when a protected request receives HTTP 401.
  /// Wired in `main.dart` / `AppRouter` to redirect to the session-expired screen.
  static void Function()? onUnauthorized;

  static void init({void Function()? onUnauthorizedCallback}) {
    onUnauthorized = onUnauthorizedCallback;
    dio = Dio(
      BaseOptions(
        baseUrl: Apis.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: const {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = SharedPref.getToken();
          if (token.isNotEmpty &&
              !options.headers.containsKey('Authorization')) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;
          final path = error.requestOptions.path;
          final isAuthAttempt =
              path == Apis.login || path == Apis.register;

          if (statusCode == 401 && !isAuthAttempt && SharedPref.isLoggedIn) {
            await SharedPref.clearSession();
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  static Future<Response<dynamic>> get({
    required String endpoint,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) =>
      dio.get(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: headers != null ? Options(headers: headers) : null,
      );

  static Future<Response<dynamic>> post({
    required String endpoint,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) =>
      dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: headers != null ? Options(headers: headers) : null,
      );

  static Future<Response<dynamic>> put({
    required String endpoint,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) =>
      dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: headers != null ? Options(headers: headers) : null,
      );

  static Future<Response<dynamic>> patch({
    required String endpoint,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) =>
      dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: headers != null ? Options(headers: headers) : null,
      );

  static Future<Response<dynamic>> delete({
    required String endpoint,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) =>
      dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: headers != null ? Options(headers: headers) : null,
      );
}
