import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/functions/extensions.dart';
import '../../../../core/functions/navigations.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/widgets/dialogs.dart';
import '../../../../core/widgets/empty_state_card.dart';
import '../../../../core/widgets/main_button.dart';
import '../cubit/garage_cubit.dart';
import '../cubit/garage_state.dart';
import '../widgets/garage_shimmer_view.dart';
import '../widgets/vehicle_card.dart';
import '../widgets/vehicle_hero_card.dart';

/// Garage tab screen matching Figma `Garage empty` (`3:164`), `Garage` (`3:181`),
/// and `Loading garage` (`10:1209`).
class GarageScreen extends StatelessWidget {
  const GarageScreen({super.key});

  Future<void> _openAddVehicle(BuildContext context) async {
    final added = await pushTo<bool>(context, Routes.addVehicle);
    if (added == true && context.mounted) {
      context.read<GarageCubit>().loadGarage();
    }
  }

  Future<void> _openVehicleDashboard(BuildContext context, int vehicleId) async {
    final changed = await pushTo<bool>(
      context,
      Routes.vehicleDashboardPath(vehicleId),
    );
    if (changed == true && context.mounted) {
      context.read<GarageCubit>().loadGarage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final textTheme = context.textTheme;

    return SafeArea(
      child: BlocBuilder<GarageCubit, GarageState>(
        builder: (context, state) {
          if (state is GarageLoading || state is GarageInitial) {
            return const GarageShimmerView();
          }

          if (state is GarageError) {
            return Padding(
              padding: AppConstants.paddingScreen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'garage.title'.tr(),
                    style: textTheme.headlineLarge?.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppConstants.space24),
                  EmptyStateCard(
                    title: 'garage.error_title'.tr(),
                    subtitle: state.message,
                  ),
                  const SizedBox(height: AppConstants.space16),
                  MainButton(
                    label: 'common.retry'.tr(),
                    onPressed: () => context.read<GarageCubit>().loadGarage(),
                  ),
                ],
              ),
            );
          }

          final loaded = state as GarageLoaded;
          return RefreshIndicator(
            onRefresh: () => context.read<GarageCubit>().loadGarage(),
            child: loaded.isEmpty
                ? _buildEmptyView(context)
                : _buildPopulatedView(context, loaded),
          );
        },
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    final scheme = context.colorScheme;
    final textTheme = context.textTheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: AppConstants.paddingScreen,
      children: [
        Text(
          'garage.title'.tr(),
          style: textTheme.headlineLarge?.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: AppConstants.space16),
        Text(
          'garage.empty_subtitle'.tr(),
          style: textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 50),
        EmptyStateCard(
          title: 'garage.empty_card_title'.tr(),
          subtitle: 'garage.empty_card_body'.tr(),
        ),
        const SizedBox(height: AppConstants.space16),
        MainButton(
          label: 'garage.add_first_car'.tr(),
          onPressed: () => _openAddVehicle(context),
        ),
        const SizedBox(height: AppConstants.space16),
        Text(
          'garage.empty_footer'.tr(),
          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildPopulatedView(BuildContext context, GarageLoaded state) {
    final scheme = context.colorScheme;
    final textTheme = context.textTheme;
    final primaryVehicle = state.ownedVehicles.isNotEmpty
        ? state.ownedVehicles.first
        : state.sharedVehicles.first;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: AppConstants.paddingScreen,
      children: [
        Text(
          'garage.title'.tr(),
          style: textTheme.headlineLarge?.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: AppConstants.space16),
        Text(
          'garage.count_subtitle'.tr(
            namedArgs: {'count': '${state.totalCount}'},
          ),
          style: textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppConstants.space16),
        if (primaryVehicle.imageUrl != null &&
            primaryVehicle.imageUrl!.isNotEmpty) ...[
          VehicleHeroCard(imageUrl: primaryVehicle.imageUrl),
          const SizedBox(height: AppConstants.space16),
        ],
        for (final vehicle in state.ownedVehicles) ...[
          VehicleCard(
            vehicle: vehicle,
            onTap: () => _openVehicleDashboard(context, vehicle.id),
          ),
          const SizedBox(height: AppConstants.space16),
        ],
        if (state.sharedVehicles.isNotEmpty) ...[
          Text(
            'garage.shared_section'.tr(),
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.space12),
          for (final vehicle in state.sharedVehicles) ...[
            VehicleCard(
              vehicle: vehicle,
              onTap: () => _openVehicleDashboard(context, vehicle.id),
            ),
            const SizedBox(height: AppConstants.space16),
          ],
        ],
        MainButton(
          label: 'garage.add_another_car'.tr(),
          variant: MainButtonVariant.secondary,
          onPressed: () => _openAddVehicle(context),
        ),
        const SizedBox(height: AppConstants.space16),
        MainButton(
          label: 'garage.invitations_cta'.tr(),
          variant: MainButtonVariant.secondary,
          onPressed: () {
            showMyDialog(context, 'garage.invitations_coming_soon'.tr());
          },
        ),
      ],
    );
  }
}
