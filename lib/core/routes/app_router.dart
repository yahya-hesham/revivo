import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/auth/presentation/pages/session_expired_screen.dart';
import '../../features/auth/presentation/pages/welcome_screen.dart';
import '../../features/dashboard/presentation/pages/dashboard_screen.dart';
import '../../features/garage/data/models/vehicle_model.dart';
import '../../features/garage/presentation/cubit/add_vehicle_cubit.dart';
import '../../features/garage/presentation/cubit/vehicle_dashboard_cubit.dart';
import '../../features/garage/presentation/pages/add_vehicle_screen.dart';
import '../../features/garage/presentation/pages/vehicle_dashboard_screen.dart';
import '../../features/garage/presentation/pages/vehicle_settings_screen.dart';
import '../../features/splash/presentation/cubit/splash_cubit.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';
import 'routes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Centralized GoRouter configuration.
/// Feature routes are wired incrementally per milestone.
abstract final class AppRouter {
  static final GoRouter routes = GoRouter(
    initialLocation: Routes.splash,
    navigatorKey: navigatorKey,
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => BlocProvider(
          create: (_) => SplashCubit()..checkSession(),
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: Routes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) => BlocProvider(
          create: (_) => AuthCubit(),
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) {
          final initialEmail =
              state.extra is String ? state.extra as String : null;
          return BlocProvider(
            create: (_) => AuthCubit(),
            child: LoginScreen(initialEmail: initialEmail),
          );
        },
      ),
      GoRoute(
        path: Routes.sessionExpired,
        builder: (context, state) => const SessionExpiredScreen(),
      ),
      GoRoute(
        path: Routes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: Routes.addVehicle,
        builder: (context, state) => BlocProvider(
          create: (_) => AddVehicleCubit()..loadMakes(),
          child: const AddVehicleScreen(),
        ),
      ),
      GoRoute(
        path: Routes.vehicleDashboard,
        builder: (context, state) {
          final vehicleId =
              int.tryParse(state.pathParameters['vehicleId'] ?? '') ?? 0;
          return BlocProvider(
            create: (_) => VehicleDashboardCubit()..loadDashboard(vehicleId),
            child: VehicleDashboardScreen(vehicleId: vehicleId),
          );
        },
      ),
      GoRoute(
        path: Routes.vehicleSettings,
        builder: (context, state) {
          final vehicle = state.extra as VehicleModel;
          return BlocProvider(
            create: (_) => VehicleDashboardCubit(),
            child: VehicleSettingsScreen(vehicle: vehicle),
          );
        },
      ),
    ],
  );
}
