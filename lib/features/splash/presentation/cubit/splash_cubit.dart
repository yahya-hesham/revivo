import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/apis/api_error.dart';
import '../../../../core/services/local/shared_pref.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/data/repository/auth_repo.dart';
import 'splash_state.dart';

/// Bootstraps the app session on startup:
/// - No token → [SplashUnauthenticated] (Welcome)
/// - Valid token (`/api/auth/me` 200) → [SplashAuthenticated] (Dashboard)
/// - Expired/invalid token (401) → [SplashSessionExpired]
/// - Offline/network error → [SplashError] (keeps token, allows retry)
class SplashCubit extends Cubit<SplashState> {
  SplashCubit({
    Future<bool> Function()? loadToken,
    bool Function()? hasToken,
    Future<UserModel> Function()? fetchCurrentUser,
    Future<void> Function(Map<String, dynamic> user)? saveUser,
    Future<void> Function()? clearSession,
    Duration minDisplayDuration = const Duration(milliseconds: 2500),
  })  : _loadToken = loadToken ??
            (hasToken != null
                ? () async => hasToken()
                : SharedPref.loadSessionToken),
        _fetchCurrentUser = fetchCurrentUser ?? AuthRepo.fetchCurrentUser,
        _saveUser = saveUser ?? SharedPref.saveUserMap,
        _clearSession = clearSession ?? SharedPref.clearSession,
        _minDisplayDuration = minDisplayDuration,
        super(const SplashInitial());

  final Future<bool> Function() _loadToken;
  final Future<UserModel> Function() _fetchCurrentUser;
  final Future<void> Function(Map<String, dynamic> user) _saveUser;
  final Future<void> Function() _clearSession;
  final Duration _minDisplayDuration;

  Future<void> checkSession() async {
    final delayFuture = _minDisplayDuration > Duration.zero
        ? Future<void>.delayed(_minDisplayDuration)
        : Future<void>.value();

    final loggedIn = await _loadToken();
    if (isClosed) return;
    emit(SplashLoading(isCheckingRemote: loggedIn));

    if (!loggedIn) {
      await delayFuture;
      if (!isClosed) emit(const SplashUnauthenticated());
      return;
    }

    try {
      final results = await Future.wait<dynamic>([
        _fetchCurrentUser(),
        delayFuture,
      ]);
      final user = results[0] as UserModel;
      await _saveUser(user.toJson());
      if (!isClosed) emit(SplashAuthenticated(user));
    } on ApiException catch (e) {
      await delayFuture;
      if (isClosed) return;
      if (e.isUnauthorized) {
        await _clearSession();
        if (!isClosed) emit(const SplashSessionExpired());
      } else {
        emit(SplashError(e.message));
      }
    } catch (_) {
      await delayFuture;
      if (!isClosed) {
        emit(const SplashError('Something went wrong. Please try again.'));
      }
    }
  }
}
