import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revivo/core/services/apis/api_error.dart';
import 'package:revivo/features/auth/data/models/auth_request_models.dart';
import 'package:revivo/features/auth/data/models/user_model.dart';
import 'package:revivo/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:revivo/features/auth/presentation/cubit/auth_state.dart';

void main() {
  group('Auth request models', () {
    test('RegisterRequestModel trims name and email', () {
      const model = RegisterRequestModel(
        name: '  Omar Hassan  ',
        email: '  omar@example.com ',
        password: 'Password1!',
      );
      expect(model.toJson(), {
        'name': 'Omar Hassan',
        'email': 'omar@example.com',
        'password': 'Password1!',
      });
    });

    test('LoginRequestModel trims email only', () {
      const model = LoginRequestModel(
        email: '  omar@example.com ',
        password: 'Password1!',
      );
      expect(model.toJson(), {
        'email': 'omar@example.com',
        'password': 'Password1!',
      });
    });
  });

  group('AuthCubit', () {
    const sampleUser = UserModel(
      id: '11111111-1111-1111-1111-111111111111',
      name: 'Omar Hassan',
      email: 'omar@example.com',
    );

    blocTest<AuthCubit, AuthState>(
      'register emits [AuthLoading, AuthRegisterSuccess] on 201',
      build: () => AuthCubit(
        registerFn: (_) async => sampleUser.id,
      ),
      act: (cubit) => cubit.register(
        name: 'Omar Hassan',
        email: ' omar@example.com ',
        password: 'Password1!',
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthRegisterSuccess>()
            .having((s) => s.userId, 'userId', sampleUser.id)
            .having((s) => s.email, 'email', 'omar@example.com'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'register preserves 400 fieldErrors in AuthError',
      build: () => AuthCubit(
        registerFn: (_) async => throw const ApiException(
          statusCode: 400,
          message: 'Email is invalid.',
          fieldErrors: {
            'email': ['Email is invalid.'],
            'password': ['Password requires a symbol.'],
          },
        ),
      ),
      act: (cubit) => cubit.register(
        name: 'Omar',
        email: 'bad',
        password: 'weak',
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>()
            .having((s) => s.fieldError('Email'), 'email', 'Email is invalid.')
            .having(
              (s) => s.fieldError('PASSWORD'),
              'password',
              'Password requires a symbol.',
            ),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'register surfaces 409 conflict',
      build: () => AuthCubit(
        registerFn: (_) async => throw const ApiException(
          statusCode: 409,
          message: 'An account with this email already exists.',
        ),
      ),
      act: (cubit) => cubit.register(
        name: 'Omar',
        email: 'omar@example.com',
        password: 'Password1!',
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>()
            .having((s) => s.isConflict, 'isConflict', true)
            .having(
              (s) => s.message,
              'message',
              'An account with this email already exists.',
            ),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'login emits [AuthLoading, AuthLoginSuccess] on 200',
      build: () => AuthCubit(
        loginFn: (_) async => sampleUser,
      ),
      act: (cubit) => cubit.login(
        email: 'omar@example.com',
        password: 'Password1!',
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthLoginSuccess>()
            .having((s) => s.user.id, 'id', sampleUser.id),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'login emits AuthError with isCredentialsError on 401',
      build: () => AuthCubit(
        loginFn: (_) async => throw const ApiException(
          statusCode: 401,
          message: 'Session expired or invalid credentials.',
        ),
      ),
      act: (cubit) => cubit.login(
        email: 'omar@example.com',
        password: 'wrong',
      ),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>()
            .having((s) => s.isCredentialsError, 'isCredentialsError', true),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'clearError resets AuthError back to AuthInitial',
      build: () => AuthCubit(),
      seed: () => const AuthError(message: 'Failed'),
      act: (cubit) => cubit.clearError(),
      expect: () => [isA<AuthInitial>()],
    );
  });
}
