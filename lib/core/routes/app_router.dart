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
import '../../features/maintenance/data/models/maintenance_models.dart';
import '../../features/maintenance/presentation/cubit/maintenance_history_cubit.dart';
import '../../features/maintenance/presentation/cubit/record_maintenance_cubit.dart';
import '../../features/maintenance/presentation/pages/maintenance_detail_screen.dart';
import '../../features/maintenance/presentation/pages/maintenance_history_screen.dart';
import '../../features/maintenance/presentation/pages/record_maintenance_screen.dart';
import '../../features/maintenance/presentation/pages/upcoming_maintenance_screen.dart';
import '../../features/splash/presentation/cubit/splash_cubit.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';
import '../../features/warranties/data/models/warranty_models.dart';
import '../../features/warranties/presentation/cubit/warranty_cubit.dart';
import '../../features/warranties/presentation/pages/warranties_screen.dart';
import '../../features/warranties/presentation/pages/warranty_detail_screen.dart';
import '../../features/warranties/presentation/pages/warranty_form_screen.dart';
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
      // Maintenance & schedules
      GoRoute(
        path: Routes.maintenanceHistory,
        builder: (context, state) {
          final vehicleId =
              int.tryParse(state.pathParameters['vehicleId'] ?? '') ?? 0;
          final extra = state.extra is Map
              ? state.extra as Map<String, dynamic>
              : const <String, dynamic>{};
          return BlocProvider(
            create: (_) => MaintenanceHistoryCubit()..loadHistory(vehicleId),
            child: MaintenanceHistoryScreen(
              vehicleId: vehicleId,
              vehicleTitle: extra['vehicleTitle'] as String?,
              isShared: (extra['isShared'] as bool?) ?? false,
            ),
          );
        },
      ),
      GoRoute(
        path: Routes.recordMaintenance,
        builder: (context, state) {
          final vehicleId =
              int.tryParse(state.pathParameters['vehicleId'] ?? '') ?? 0;
          return BlocProvider(
            create: (_) => RecordMaintenanceCubit(),
            child: RecordMaintenanceScreen(vehicleId: vehicleId),
          );
        },
      ),
      GoRoute(
        path: Routes.maintenanceDetail,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final record = extra['record'] as MaintenanceRecordModel;
          final isShared = (extra['isShared'] as bool?) ?? false;
          return BlocProvider(
            create: (_) => RecordMaintenanceCubit(),
            child: MaintenanceDetailScreen(record: record, isShared: isShared),
          );
        },
      ),
      GoRoute(
        path: Routes.editMaintenance,
        builder: (context, state) {
          final vehicleId =
              int.tryParse(state.pathParameters['vehicleId'] ?? '') ?? 0;
          final record = state.extra as MaintenanceRecordModel;
          return BlocProvider(
            create: (_) => RecordMaintenanceCubit(),
            child: RecordMaintenanceScreen(
              vehicleId: vehicleId,
              existingRecord: record,
            ),
          );
        },
      ),
      GoRoute(
        path: Routes.upcomingMaintenance,
        builder: (context, state) {
          final vehicleId =
              int.tryParse(state.pathParameters['vehicleId'] ?? '') ?? 0;
          return BlocProvider(
            create: (_) => MaintenanceHistoryCubit()..loadUpcoming(vehicleId),
            child: UpcomingMaintenanceScreen(vehicleId: vehicleId),
          );
        },
      ),
      // Warranties
      GoRoute(
        path: Routes.warranties,
        builder: (context, state) {
          final vehicleId =
              int.tryParse(state.pathParameters['vehicleId'] ?? '') ?? 0;
          final extra = state.extra is Map
              ? state.extra as Map<String, dynamic>
              : const <String, dynamic>{};
          return BlocProvider(
            create: (_) => WarrantyCubit()..loadWarranties(vehicleId),
            child: WarrantiesScreen(
              vehicleId: vehicleId,
              vehicleTitle: extra['vehicleTitle'] as String?,
              isShared: (extra['isShared'] as bool?) ?? false,
            ),
          );
        },
      ),
      GoRoute(
        path: Routes.warrantyDetail,
        builder: (context, state) {
          final vehicleId =
              int.tryParse(state.pathParameters['vehicleId'] ?? '') ?? 0;
          final recordId =
              int.tryParse(state.pathParameters['recordId'] ?? '') ?? 0;
          final extra = state.extra is Map
              ? state.extra as Map<String, dynamic>
              : const <String, dynamic>{};
          return BlocProvider(
            create: (_) => WarrantyCubit()
              ..loadRecordWarranty(vehicleId: vehicleId, recordId: recordId),
            child: WarrantyDetailScreen(
              vehicleId: vehicleId,
              recordId: recordId,
              itemName: extra['itemName'] as String?,
              isShared: (extra['isShared'] as bool?) ?? false,
            ),
          );
        },
      ),
      GoRoute(
        path: Routes.warrantyForm,
        builder: (context, state) {
          final vehicleId =
              int.tryParse(state.pathParameters['vehicleId'] ?? '') ?? 0;
          final recordId =
              int.tryParse(state.pathParameters['recordId'] ?? '') ?? 0;
          final extra = state.extra is Map
              ? state.extra as Map<String, dynamic>
              : const <String, dynamic>{};
          return BlocProvider(
            create: (_) => WarrantyCubit(),
            child: WarrantyFormScreen(
              vehicleId: vehicleId,
              recordId: recordId,
              existingWarranty: extra['warranty'] as WarrantyModel?,
              itemName: extra['itemName'] as String?,
            ),
          );
        },
      ),
    ],
  );
}
