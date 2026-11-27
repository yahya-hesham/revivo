import 'package:dio/dio.dart';

/// Normalized API error covering all Revivo backend error shapes:
/// - 400 validation problem+json (`errors` map, sometimes PascalCase keys)
/// - 400 bare / non-JSON binding errors
/// - 401 unauthorized (empty body)
/// - 404 not found or no access (empty body)
/// - 409 business conflict (`{ "message": "..." }`)
/// - 5xx / network / timeout errors
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.fieldErrors = const {},
    this.isNetworkError = false,
  });

  final String message;
  final int? statusCode;

  /// Field-level validation errors keyed by lowercase field name for lookup.
  final Map<String, List<String>> fieldErrors;
  final bool isNetworkError;

  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;
  bool get isValidation => statusCode == 400 && fieldErrors.isNotEmpty;

  /// Case-insensitive lookup for a field's first error message.
  String? fieldError(String fieldName) {
    final errors = fieldErrors[fieldName.toLowerCase()];
    if (errors == null || errors.isEmpty) return null;
    return errors.first;
  }

  factory ApiException.fromDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const ApiException(
        message: 'Unable to reach the server. Check your connection.',
        isNetworkError: true,
      );
    }

    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    if (statusCode == 401) {
      return const ApiException(
        statusCode: 401,
        message: 'Session expired or invalid credentials.',
      );
    }

    if (statusCode == 404) {
      return const ApiException(
        statusCode: 404,
        message: 'The requested resource was not found.',
      );
    }

    if (statusCode == 409) {
      final conflictMsg = _extractConflictMessage(data);
      return ApiException(
        statusCode: 409,
        message: conflictMsg ?? 'This action conflicts with existing data.',
      );
    }

    if (statusCode == 400) {
      final parsedFields = _extractValidationErrors(data);
      final firstFieldMsg = parsedFields.values
          .expand((list) => list)
          .cast<String?>()
          .firstWhere((m) => m != null && m.isNotEmpty, orElse: () => null);
      final fallback = _extractGenericMessage(data);
      return ApiException(
        statusCode: 400,
        message: firstFieldMsg ?? fallback ?? 'Please check your input.',
        fieldErrors: parsedFields,
      );
    }

    final fallback = _extractGenericMessage(data);
    return ApiException(
      statusCode: statusCode,
      message: fallback ?? e.message ?? 'Something went wrong. Please try again.',
    );
  }

  static String? _extractConflictMessage(dynamic data) {
    if (data is Map) {
      final msg = data['message'] ?? data['Message'];
      if (msg is String && msg.trim().isNotEmpty) return msg.trim();
    }
    if (data is String && data.trim().isNotEmpty) return data.trim();
    return null;
  }

  static Map<String, List<String>> _extractValidationErrors(dynamic data) {
    if (data is! Map) return const {};
    final rawErrors = data['errors'] ?? data['Errors'];
    if (rawErrors is! Map) return const {};

    final result = <String, List<String>>{};
    rawErrors.forEach((key, value) {
      final normalizedKey = key.toString().trim().toLowerCase();
      if (value is List) {
        final messages = value
            .map((e) => e.toString().trim())
            .where((s) => s.isNotEmpty)
            .toList();
        if (messages.isNotEmpty) {
          result[normalizedKey] = messages;
        }
      } else if (value != null && value.toString().trim().isNotEmpty) {
        result[normalizedKey] = [value.toString().trim()];
      }
    });
    return result;
  }

  static String? _extractGenericMessage(dynamic data) {
    if (data is String && data.trim().isNotEmpty) return data.trim();
    if (data is Map) {
      for (final key in ['message', 'Message', 'title', 'Title', 'error']) {
        final value = data[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
      }
    }
    return null;
  }

  @override
  String toString() => message;
}
