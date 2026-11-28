import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/functions/extensions.dart';
import '../../../../core/functions/navigations.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/widgets/empty_state_card.dart';
import '../../../../core/widgets/main_button.dart';
import '../../../../core/widgets/shimmer/app_shimmer.dart';
import '../../data/models/maintenance_models.dart';
import '../cubit/maintenance_history_cubit.dart';
import '../cubit/maintenance_history_state.dart';

/// Paginated maintenance history matching Figma `Maintenance history` (`4:2`)
/// and `History empty` (`4:260`).
class MaintenanceHistoryScreen extends StatelessWidget {
  const MaintenanceHistoryScreen({
    super.key,
    required this.vehicleId,
    this.vehicleTitle,
    this.isShared = false,
  });

  final int vehicleId;
  final String? vehicleTitle;
  final bool isShared;

  Future<void> _openRecord(BuildContext context) async {
    final saved = await pushTo<bool>(
      context,
      Routes.recordMaintenancePath(vehicleId),
    );
    if (saved == true && context.mounted) {
      context.read<MaintenanceHistoryCubit>().loadHistory(vehicleId);
    }
  }

  Future<void> _openDetail(
    BuildContext context,
    MaintenanceRecordModel record,
  ) async {
    final changed = await pushTo<bool>(
      context,
      Routes.maintenanceDetailPath(vehicleId, record.id),
      extra: {'record': record, 'isShared': isShared},
    );
    if (changed == true && context.mounted) {
      context.read<MaintenanceHistoryCubit>().loadHistory(vehicleId);
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
                          .loadHistory(vehicleId),
                    ),
                  ],
                ),
              );
            }

            final loaded = state as MaintenanceHistoryLoaded;
            if (loaded.items.isEmpty) {
              return _buildEmpty(context, scheme, textTheme);
            }

            final kmFormat = NumberFormat.decimalPattern();
            final egpFormat = NumberFormat('#,##0.##');

            return RefreshIndicator(
              onRefresh: () => context
                  .read<MaintenanceHistoryCubit>()
                  .loadHistory(vehicleId),
              child: ListView(
                padding: AppConstants.paddingScreen,
                children: [
                  Text(
                    'maintenance.history_title'.tr(),
                    style: textTheme.headlineLarge?.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppConstants.space8),
                  Text(
                    vehicleTitle != null
                        ? '$vehicleTitle · ${'maintenance.history_subtitle'.tr()}'
                        : 'maintenance.history_subtitle'.tr(),
                    style: textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  if (!isShared) ...[
                    const SizedBox(height: AppConstants.space16),
                    MainButton(
                      label: 'garage.record_maintenance'.tr(),
                      onPressed: () => _openRecord(context),
                    ),
                  ],
                  const SizedBox(height: AppConstants.space16),
                  for (final record in loaded.items) ...[
                    Material(
                      color: scheme.surface,
                      borderRadius: AppConstants.borderRadius20,
                      child: InkWell(
                        onTap: () => _openDetail(context, record),
                        borderRadius: AppConstants.borderRadius20,
                        child: Padding(
                          padding: AppConstants.paddingCard,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      record.itemName,
                                      style: textTheme.titleLarge?.copyWith(
                                        color: scheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: AppConstants.space8),
                                    Text(
                                      '${record.maintenanceDate} • ${kmFormat.format(record.mileageKm)} ${'garage.km_unit'.tr()} • EGP ${egpFormat.format(record.costEgp)}',
                                      style: textTheme.bodyLarge?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: scheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.space12),
                  ],
                  if (loaded.hasMore) ...[
                    MainButton(
                      label: 'maintenance.load_more'.tr(),
                      variant: MainButtonVariant.secondary,
                      isLoading: loaded.isLoadingMore,
                      onPressed: () => context
                          .read<MaintenanceHistoryCubit>()
                          .loadMore(vehicleId),
                    ),
                    const SizedBox(height: AppConstants.space12),
                  ],
                  const SizedBox(height: AppConstants.space4),
                  MainButton(
                    label: 'maintenance.upcoming_cta'.tr(),
                    variant: MainButtonVariant.secondary,
                    onPressed: () => pushTo(
                      context,
                      Routes.upcomingMaintenancePath(vehicleId),
                    ),
                  ),
                  const SizedBox(height: AppConstants.space12),
                  MainButton(
                    label: 'warranties.title_short'.tr(),
                    variant: MainButtonVariant.secondary,
                    onPressed: () => pushTo(
                      context,
                      Routes.warrantiesPath(vehicleId),
                      extra: {'vehicleTitle': vehicleTitle, 'isShared': isShared},
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmpty(
    BuildContext context,
    ColorScheme scheme,
    TextTheme textTheme,
  ) {
    return ListView(
      padding: AppConstants.paddingScreen,
      children: [
        Text(
          'maintenance.empty_title'.tr(),
          style: textTheme.headlineLarge?.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: AppConstants.space12),
        Text(
          'maintenance.empty_subtitle'.tr(),
          style: textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 40),
        EmptyStateCard(
          title: 'maintenance.empty_card_title'.tr(),
          subtitle: 'maintenance.empty_card_body'.tr(),
        ),
        if (!isShared) ...[
          const SizedBox(height: AppConstants.space16),
          MainButton(
            label: 'garage.record_maintenance'.tr(),
            onPressed: () => _openRecord(context),
          ),
        ],
      ],
    );
  }
}
