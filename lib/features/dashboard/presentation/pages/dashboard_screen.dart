import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/functions/extensions.dart';
import '../../../garage/presentation/cubit/garage_cubit.dart';
import '../../../garage/presentation/pages/garage_screen.dart';
import '../widgets/main_layout.dart';

/// Authenticated home shell with 3 tabs: Garage, Alerts, Account.
/// Alerts and Account tabs are wired in Milestones 7 and 9.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      initialIndex: initialIndex,
      tabs: [
        NavTabItem(
          label: 'nav.garage'.tr(),
          iconPath: AppAssets.navGarage,
          screen: BlocProvider(
            create: (_) => GarageCubit()..loadGarage(),
            child: const GarageScreen(),
          ),
        ),
        NavTabItem(
          label: 'nav.alerts'.tr(),
          iconPath: AppAssets.navAlerts,
          screen: _TabPlaceholder(
            title: 'nav.alerts'.tr(),
            milestoneHint: 'Milestone 7 — Alerts & Preferences',
          ),
        ),
        NavTabItem(
          label: 'nav.account'.tr(),
          iconPath: AppAssets.navAccount,
          screen: _TabPlaceholder(
            title: 'nav.account'.tr(),
            milestoneHint: 'Milestone 9 — Account',
          ),
        ),
      ],
    );
  }
}

class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder({
    required this.title,
    required this.milestoneHint,
  });

  final String title;
  final String milestoneHint;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: AppConstants.paddingScreen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: context.textTheme.headlineLarge?.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppConstants.space8),
            Text(
              milestoneHint,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
