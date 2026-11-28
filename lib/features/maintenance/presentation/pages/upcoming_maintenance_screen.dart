import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/functions/extensions.dart';
import '../../../../core/functions/navigations.dart';
import '../../../../core/widgets/empty_state_card.dart';
import '../../../../core/widgets/main_button.dart';
import '../../../../core/widgets/shimmer/app_shimmer.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../data/models/maintenance_models.dart';
import '../cubit/maintenance_history_cubit.dart';
import '../cubit/maintenance_history_state.dart';

/// Upcoming & scheduled maintenance screen matching Figma `Upcoming maintenance` (`4:87`).
class UpcomingMaintenanceScreen extends StatelessWidget {
  const UpcomingMaintenanceScreen({super.key, required this.vehicleId});

  final int vehicleId;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => pop(context),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<MaintenanceHistoryCubit, MaintenanceHistoryState>(
          builder: (context, state) {
            if (state is MaintenanceHistoryLoading ||
                state is MaintenanceHistoryInitial) {
              return ListView(
                padding: AppConstants.paddingScreen,
                children: const [
                  AppShimmerBox(height: 32, width: 180),
                  SizedBox(height: AppConstants.space16),
                  AppShimmerBox(height: 92),
                  SizedBox(height: AppConstants.space12),
                  AppShimmerBox(height: 92),
                ],
              );
            }

            if (state is MaintenanceHistoryError) {
              return Padding(
                padding: AppConstants.paddingScreen,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EmptyStateCard(
                      title: 'garage.error_title'.tr(),
                      subtitle: state.message,
                    ),
                    const SizedBox(height: AppConstants.space16),
                    MainButton(
                      label: 'common.retry'.tr(),
                      onPressed: () => context
                          .read<MaintenanceHistoryCubit>()
                          .loadUpcoming(vehicleId),
                    ),
                  ],
                ),
              );
            }

            final loaded = state as MaintenanceStatusLoaded;
            final listToShow = loaded.allStatuses.isNotEmpty
                ? loaded.allStatuses
                : loaded.upcoming;

            return RefreshIndicator(
              onRefresh: () => context
                  .read<MaintenanceHistoryCubit>()
                  .loadUpcoming(vehicleId),
              child: ListView(
                padding: AppConstants.paddingScreen,
                children: [
                  Text(
                    'maintenance.upcoming_title'.tr(),
                    style: textTheme.headlineLarge?.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppConstants.space8),
                  Text(
                    'maintenance.upcoming_subtitle'.tr(),
                    style: textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppConstants.space16),
                  if (listToShow.isEmpty)
                    EmptyStateCard(
                      title: 'garage.all_clear_title'.tr(),
                      subtitle: 'garage.all_clear_body'.tr(),
                    )
                  else
                    for (final item in listToShow) ...[
                      _StatusItemCard(item: item),
                      const SizedBox(height: AppConstants.space12),
                    ],
                  const SizedBox(height: AppConstants.space8),
                  MainButton(
                    label: 'maintenance.return_to_car'.tr(),
                    variant: MainButtonVariant.secondary,
                    onPressed: () => pop(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatusItemCard extends StatelessWidget {
  const _StatusItemCard({required this.item});

  final MaintenanceStatusModel item;

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
    final textTheme = context.textTheme;
    final kmFormat = NumberFormat.decimalPattern();

    final dueParts = <String>[
      if (item.nextDueMileageKm != null)
        '${kmFormat.format(item.nextDueMileageKm)} ${'garage.km_unit'.tr()}',
      if (item.remainingKm != null)
        '${kmFormat.format(item.remainingKm)} ${'garage.km_remaining'.tr()}',
      if (item.nextDueDate != null) item.nextDueDate!,
      if (item.remainingDays != null)
        '${item.remainingDays} ${'garage.days_remaining'.tr()}',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.hasNextDue) ...[
          StatusChip(
            label: _chipLabel(item.status),
            type: _chipType(item.status),
          ),
          const SizedBox(height: AppConstants.space8),
        ],
        Container(
          width: double.infinity,
          padding: AppConstants.paddingCard,
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: AppConstants.borderRadius20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.itemName,
                style: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
              ),
              const SizedBox(height: AppConstants.space8),
              Text(
                item.hasNextDue
                    ? dueParts.join(' • ')
                    : 'garage.no_next_service'.tr(),
                style: textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (item.lastMaintenanceDate != null ||
            item.lastMaintenanceMileage != null) ...[
          const SizedBox(height: AppConstants.space8),
          Text(
            '${'maintenance.last_service'.tr()} · ${item.lastMaintenanceMileage != null ? '${kmFormat.format(item.lastMaintenanceMileage)} ${'garage.km_unit'.tr()}' : ''}${item.lastMaintenanceDate != null ? ' (${item.lastMaintenanceDate})' : ''}',
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
