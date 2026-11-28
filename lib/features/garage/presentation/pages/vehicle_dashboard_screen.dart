import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/functions/extensions.dart';
import '../../../../core/functions/navigations.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/styles/colors.dart';
import '../../../../core/widgets/dialogs.dart';
import '../../../../core/widgets/empty_state_card.dart';
import '../../../../core/widgets/main_button.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../data/models/vehicle_model.dart';
import '../cubit/vehicle_dashboard_cubit.dart';
import '../cubit/vehicle_dashboard_state.dart';
import '../widgets/garage_shimmer_view.dart';
import '../widgets/vehicle_hero_card.dart';

/// Vehicle Dashboard matching Figma `Dashboard` (`3:288`), `Dashboard dark` (`3:350`),
/// and `Image unavailable` (`10:1234`).
class VehicleDashboardScreen extends StatelessWidget {
  const VehicleDashboardScreen({super.key, required this.vehicleId});

  final int vehicleId;

  Future<void> _openSettings(
    BuildContext context,
    VehicleModel vehicle,
  ) async {
    final result = await pushTo<String>(
      context,
      Routes.vehicleSettingsPath(vehicle.id),
      extra: vehicle,
    );
    if (!context.mounted) return;
    if (result == 'deleted') {
      pop(context, true);
    } else if (result == 'updated') {
      context.read<VehicleDashboardCubit>().loadDashboard(vehicleId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => pop(context, true),
        ),
        actions: [
          BlocBuilder<VehicleDashboardCubit, VehicleDashboardState>(
            builder: (context, state) {
              if (state is VehicleDashboardLoaded && !state.data.vehicle.isShared) {
                return IconButton(
                  tooltip: 'garage.vehicle_details_title'.tr(),
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => _openSettings(context, state.data.vehicle),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<VehicleDashboardCubit, VehicleDashboardState>(
          builder: (context, state) {
            if (state is VehicleDashboardLoading ||
                state is VehicleDashboardInitial) {
              return const GarageShimmerView();
            }

            if (state is VehicleDashboardError) {
              return Padding(
                padding: AppConstants.paddingScreen,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EmptyStateCard(
                      title: state.isNotFound
                          ? 'garage.access_removed_title'.tr()
                          : 'garage.error_title'.tr(),
                      subtitle: state.isNotFound
                          ? 'garage.access_removed_body'.tr()
                          : state.message,
                    ),
                    const SizedBox(height: AppConstants.space16),
                    MainButton(
                      label: state.isNotFound
                          ? 'garage.back_to_garage'.tr()
                          : 'common.retry'.tr(),
                      onPressed: () {
                        if (state.isNotFound) {
                          pop(context, true);
                        } else {
                          context
                              .read<VehicleDashboardCubit>()
                              .loadDashboard(vehicleId);
                        }
                      },
                    ),
                  ],
                ),
              );
            }

            final data = (state as VehicleDashboardLoaded).data;
            final vehicle = data.vehicle;
            final kmFormatted = NumberFormat.decimalPattern().format(
              vehicle.currentMileageKm,
            );
            final egpFormat = NumberFormat('#,##0.##');

            return RefreshIndicator(
              onRefresh: () => context
                  .read<VehicleDashboardCubit>()
                  .loadDashboard(vehicleId),
              child: ListView(
                padding: AppConstants.paddingScreen,
                children: [
                  Text(
                    vehicle.displayTitle,
                    style: textTheme.headlineLarge?.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppConstants.space8),
                  Text(
                    '${vehicle.catalogTitle} · ${vehicle.year}',
                    style: textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  if (vehicle.isShared) ...[
                    const SizedBox(height: AppConstants.space12),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: StatusChip(
                        label: 'garage.read_only'.tr(),
                        type: StatusChipType.readOnly,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppConstants.space16),
                  VehicleHeroCard(imageUrl: vehicle.imageUrl),
                  const SizedBox(height: AppConstants.space16),
                  // Teal odometer hero card matching Figma `Statistics card` (`3:42`)
                  Container(
                    width: double.infinity,
                    padding: AppConstants.paddingCard,
                    decoration: BoxDecoration(
                      color: AppColors.teal,
                      borderRadius: AppConstants.borderRadius20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$kmFormatted ${'garage.km_unit'.tr()}',
                          style: textTheme.displayLarge?.copyWith(
                            color: AppColors.onBrand,
                          ),
                        ),
                        const SizedBox(height: AppConstants.space8),
                        Text(
                          'garage.current_odometer'.tr(),
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.onBrand.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!vehicle.isShared) ...[
                    const SizedBox(height: AppConstants.space16),
                    MainButton(
                      label: 'garage.update_mileage'.tr(),
                      variant: MainButtonVariant.secondary,
                      onPressed: () {
                        showMyDialog(context, 'garage.milestone_next_hint'.tr());
                      },
                    ),
                    const SizedBox(height: AppConstants.space12),
                    MainButton(
                      label: 'garage.record_maintenance'.tr(),
                      onPressed: () async {
                        final saved = await pushTo<bool>(
                          context,
                          Routes.recordMaintenancePath(vehicle.id),
                        );
                        if (saved == true && context.mounted) {
                          context
                              .read<VehicleDashboardCubit>()
                              .loadDashboard(vehicleId);
                        }
                      },
                    ),
                  ],
                  const SizedBox(height: AppConstants.space12),
                  Row(
                    children: [
                      Expanded(
                        child: MainButton(
                          label: 'maintenance.history_title'.tr(),
                          variant: MainButtonVariant.secondary,
                          onPressed: () async {
                            final changed = await pushTo<bool>(
                              context,
                              Routes.maintenanceHistoryPath(vehicle.id),
                              extra: {
                                'vehicleTitle': vehicle.catalogTitle,
                                'isShared': vehicle.isShared,
                              },
                            );
                            if (changed == true && context.mounted) {
                              context
                                  .read<VehicleDashboardCubit>()
                                  .loadDashboard(vehicleId);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: AppConstants.space12),
                      Expanded(
                        child: MainButton(
                          label: 'warranties.title_short'.tr(),
                          variant: MainButtonVariant.secondary,
                          onPressed: () => pushTo(
                            context,
                            Routes.warrantiesPath(vehicle.id),
                            extra: {
                              'vehicleTitle': vehicle.catalogTitle,
                              'isShared': vehicle.isShared,
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.space24),
                  Text(
                    'garage.next_up'.tr(),
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppConstants.space12),
                  if (data.upcomingItems.isEmpty)
                    EmptyStateCard(
                      title: 'garage.all_clear_title'.tr(),
                      subtitle: 'garage.all_clear_body'.tr(),
                    )
                  else
                    for (final item in data.upcomingItems) ...[
                      _UpcomingItemCard(item: item),
                      const SizedBox(height: AppConstants.space12),
                    ],
                  if (data.overview != null) ...[
                    const SizedBox(height: AppConstants.space12),
                    EmptyStateCard(
                      title:
                          '${egpFormat.format(data.overview!.lifetimeMaintenanceCost)} ${data.overview!.currency}',
                      subtitle: 'garage.lifetime_spending_subtitle'.tr(
                        namedArgs: {
                          'count': '${data.overview!.maintenanceOperationsCount}',
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _UpcomingItemCard extends StatelessWidget {
  const _UpcomingItemCard({required this.item});

  final UpcomingItemSummary item;

  StatusChipType _chipType(String status) {
    switch (status.toLowerCase()) {
      case 'overdue':
        return StatusChipType.overdue;
      case 'duesoon':
        return StatusChipType.dueSoon;
      default:
        return StatusChipType.onTrack;
    }
  }

  String _chipLabel(String status) {
    switch (status.toLowerCase()) {
      case 'overdue':
        return 'garage.status_overdue'.tr();
      case 'duesoon':
        return 'garage.status_due_soon'.tr();
      default:
        return 'garage.status_on_track'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final kmFormat = NumberFormat.decimalPattern();
    final parts = <String>[
      if (item.nextDueMileageKm != null)
        '${'garage.due_at'.tr()} ${kmFormat.format(item.nextDueMileageKm)} ${'garage.km_unit'.tr()}',
      if (item.remainingKm != null)
        '${kmFormat.format(item.remainingKm)} ${'garage.km_remaining'.tr()}',
      if (item.remainingDays != null)
        '${item.remainingDays} ${'garage.days_remaining'.tr()}',
    ];

    return Container(
      width: double.infinity,
      padding: AppConstants.paddingCard,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppConstants.borderRadius20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.itemName,
                  style: context.textTheme.titleLarge?.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.space8),
              StatusChip(
                label: _chipLabel(item.status),
                type: _chipType(item.status),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.space8),
          Text(
            parts.isEmpty ? 'garage.no_next_service'.tr() : parts.join(' • '),
            style: context.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
