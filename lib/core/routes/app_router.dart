import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
      // Temporary placeholders until Milestones 2 (Auth) & 3 (Dashboard)
      GoRoute(
        path: Routes.welcome,
        builder: (context, state) => const _MilestonePlaceholder(
          title: 'Welcome',
          subtitle: 'Milestone 2 — Authentication',
        ),
      ),
      GoRoute(
        path: Routes.sessionExpired,
        builder: (context, state) => const _MilestonePlaceholder(
          title: 'Session Expired',
          subtitle: 'Milestone 2 — Authentication',
        ),
      ),
      GoRoute(
        path: Routes.dashboard,
        builder: (context, state) => const _MilestonePlaceholder(
          title: 'Dashboard',
          subtitle: 'Milestone 3 — Dashboard Shell',
        ),
      ),
    ],
  );
}

class _MilestonePlaceholder extends StatelessWidget {
  const _MilestonePlaceholder({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
