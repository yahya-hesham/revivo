import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/apis/api_error.dart';
import '../../data/models/auth_request_models.dart';
import '../../data/models/user_model.dart';
import '../../data/repository/auth_repo.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    Future<String> Function(RegisterRequestModel)? registerFn,
    Future<UserModel> Function(LoginRequestModel)? loginFn,
  })  : _registerFn = registerFn ?? AuthRepo.register,
        _loginFn = loginFn ?? AuthRepo.login,
        super(const AuthInitial());

  final Future<String> Function(RegisterRequestModel) _registerFn;
  final Future<UserModel> Function(LoginRequestModel) _loginFn;

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    try {
      final request = RegisterRequestModel(
        name: name,
        email: email,
        password: password,
      );
      final userId = await _registerFn(request);
      if (!isClosed) {
        emit(AuthRegisterSuccess(userId: userId, email: email.trim()));
      }
    } on ApiException catch (e) {
      if (!isClosed) {
        emit(
          AuthError(
            message: e.message,
            fieldErrors: e.fieldErrors,
            statusCode: e.statusCode,
            isNetworkError: e.isNetworkError,
          ),
        );
      }
    } catch (_) {
      if (!isClosed) {
        emit(
          const AuthError(
            message: 'Something went wrong. Please try again.',
          ),
        );
      }
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    try {
      final request = LoginRequestModel(email: email, password: password);
      final user = await _loginFn(request);
      if (!isClosed) {
        emit(AuthLoginSuccess(user));
      }
    } on ApiException catch (e) {
      if (!isClosed) {
        emit(
          AuthError(
            message: e.message,
            fieldErrors: e.fieldErrors,
            statusCode: e.statusCode,
            isNetworkError: e.isNetworkError,
          ),
        );
      }
    } catch (_) {
      if (!isClosed) {
        emit(
          const AuthError(
            message: 'Something went wrong. Please try again.',
          ),
        );
      }
    }
  }

  void clearError() {
    if (state is AuthError) {
      emit(const AuthInitial());
    }
  }
}
