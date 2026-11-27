import '../../../auth/data/models/user_model.dart';

abstract class SplashState {
  const SplashState();
}

class SplashInitial extends SplashState {
  const SplashInitial();
}

class SplashLoading extends SplashState {
  const SplashLoading({this.isCheckingRemote = false});

  /// True when a saved token exists and `/api/auth/me` is in flight.
  final bool isCheckingRemote;
}

class SplashAuthenticated extends SplashState {
  const SplashAuthenticated(this.user);

  final UserModel user;
}

class SplashUnauthenticated extends SplashState {
  const SplashUnauthenticated();
}

class SplashSessionExpired extends SplashState {
  const SplashSessionExpired();
}

class SplashError extends SplashState {
  const SplashError(this.message);

  final String message;
}
