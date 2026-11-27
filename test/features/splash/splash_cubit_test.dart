import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revivo/core/services/apis/api_error.dart';
import 'package:revivo/features/auth/data/models/user_model.dart';
import 'package:revivo/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:revivo/features/splash/presentation/cubit/splash_state.dart';

void main() {
  group('UserModel', () {
    test('parses camelCase JSON and serializes back', () {
      final json = {
        'id': '11111111-1111-1111-1111-111111111111',
        'name': 'Sample Driver',
        'email': 'driver@example.com',
      };
      final user = UserModel.fromJson(json);

      expect(user.id, '11111111-1111-1111-1111-111111111111');
      expect(user.name, 'Sample Driver');
      expect(user.email, 'driver@example.com');
      expect(user.toJson(), json);
    });

    test('handles nullable name and email', () {
      final user =
          UserModel.fromJson({'id': 'abc', 'name': null, 'email': null});
      expect(user.id, 'abc');
      expect(user.name, isNull);
      expect(user.email, isNull);
    });
  });

  group('SplashCubit', () {
    const sampleUser = UserModel(
      id: '11111111-1111-1111-1111-111111111111',
      name: 'Sample Driver',
      email: 'driver@example.com',
    );

    Map<String, dynamic>? savedUser;
    var sessionCleared = false;

    setUp(() {
      savedUser = null;
      sessionCleared = false;
    });

    blocTest<SplashCubit, SplashState>(
      'emits [SplashLoading(false), SplashUnauthenticated] when no token exists',
      build: () => SplashCubit(
        hasToken: () => false,
        minDisplayDuration: Duration.zero,
      ),
      act: (cubit) => cubit.checkSession(),
      expect: () => [
        isA<SplashLoading>().having((s) => s.isCheckingRemote, 'remote', false),
        isA<SplashUnauthenticated>(),
      ],
    );

    blocTest<SplashCubit, SplashState>(
      'emits [SplashLoading(true), SplashAuthenticated] and caches user on 200',
      build: () => SplashCubit(
        hasToken: () => true,
        fetchCurrentUser: () async => sampleUser,
        saveUser: (user) async => savedUser = user,
        minDisplayDuration: Duration.zero,
      ),
      act: (cubit) => cubit.checkSession(),
      expect: () => [
        isA<SplashLoading>().having((s) => s.isCheckingRemote, 'remote', true),
        isA<SplashAuthenticated>()
            .having((s) => s.user.id, 'id', sampleUser.id),
      ],
      verify: (_) {
        expect(savedUser, sampleUser.toJson());
      },
    );

    blocTest<SplashCubit, SplashState>(
      'emits [SplashLoading(true), SplashSessionExpired] and clears session on 401',
      build: () => SplashCubit(
        hasToken: () => true,
        fetchCurrentUser: () async => throw const ApiException(
          statusCode: 401,
          message: 'Unauthorized',
        ),
        clearSession: () async => sessionCleared = true,
        minDisplayDuration: Duration.zero,
      ),
      act: (cubit) => cubit.checkSession(),
      expect: () => [
        isA<SplashLoading>().having((s) => s.isCheckingRemote, 'remote', true),
        isA<SplashSessionExpired>(),
      ],
      verify: (_) {
        expect(sessionCleared, isTrue);
      },
    );

    blocTest<SplashCubit, SplashState>(
      'emits [SplashLoading(true), SplashError] without clearing token on network error',
      build: () => SplashCubit(
        hasToken: () => true,
        fetchCurrentUser: () async => throw const ApiException(
          message: 'No connection',
          isNetworkError: true,
        ),
        clearSession: () async => sessionCleared = true,
        minDisplayDuration: Duration.zero,
      ),
      act: (cubit) => cubit.checkSession(),
      expect: () => [
        isA<SplashLoading>().having((s) => s.isCheckingRemote, 'remote', true),
        isA<SplashError>().having((s) => s.message, 'message', 'No connection'),
      ],
      verify: (_) {
        expect(sessionCleared, isFalse);
      },
    );
  });
}
