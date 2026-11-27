import '../../data/models/user_model.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthRegisterSuccess extends AuthState {
  const AuthRegisterSuccess({required this.userId, required this.email});

  final String userId;
  final String email;
}

class AuthLoginSuccess extends AuthState {
  const AuthLoginSuccess(this.user);

  final UserModel user;
}

class AuthError extends AuthState {
  const AuthError({
    required this.message,
    this.fieldErrors = const {},
    this.statusCode,
    this.isNetworkError = false,
  });

  final String message;
  final Map<String, List<String>> fieldErrors;
  final int? statusCode;
  final bool isNetworkError;

  bool get isCredentialsError => statusCode == 401;
  bool get isConflict => statusCode == 409;

  /// Case-insensitive lookup for a field's first server validation message.
  String? fieldError(String fieldName) {
    final errors = fieldErrors[fieldName.toLowerCase()];
    if (errors == null || errors.isEmpty) return null;
    return errors.first;
  }
}
