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
import '../../../../core/widgets/status_chip.dart';
import '../../data/models/warranty_models.dart';
import '../cubit/warranty_cubit.dart';
import '../cubit/warranty_state.dart';

/// Vehicle warranties list screen matching Figma `Warranties` (`4:162`).
class WarrantiesScreen extends StatelessWidget {
  const WarrantiesScreen({
    super.key,
    required this.vehicleId,
    this.vehicleTitle,
    this.isShared = false,
  });

  final int vehicleId;
  final String? vehicleTitle;
  final bool isShared;

  StatusChipType _chipType(String status) {
    switch (status.toLowerCase()) {
      case 'expired':
        return StatusChipType.overdue;
      case 'expiringsoon':
        return StatusChipType.dueSoon;
      default:
        return StatusChipType.onTrack;
    }
  }

  String _chipLabel(String status) {
    switch (status.toLowerCase()) {
      case 'expired':
        return 'warranties.status_expired'.tr();
      case 'expiringsoon':
        return 'warranties.status_expiring_soon'.tr();
      default:
        return 'warranties.status_active'.tr();
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
          onPressed: () => pop(context),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<WarrantyCubit, WarrantyState>(
          builder: (context, state) {
            if (state is WarrantyLoading || state is WarrantyInitial) {
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

            if (state is WarrantyError) {
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
                      onPressed: () =>
                          context.read<WarrantyCubit>().loadWarranties(vehicleId),
                    ),
                  ],
                ),
              );
            }

            final warranties = (state as WarrantiesListLoaded).warranties;

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<WarrantyCubit>().loadWarranties(vehicleId),
              child: ListView(
                padding: AppConstants.paddingScreen,
                children: [
                  Text(
                    'warranties.title'.tr(),
                    style: textTheme.headlineLarge?.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppConstants.space8),
                  Text(
                    vehicleTitle != null
                        ? '$vehicleTitle · ${'warranties.title_short'.tr()}'
                        : 'warranties.title_short'.tr(),
                    style: textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppConstants.space16),
                  if (warranties.isEmpty)
                    EmptyStateCard(
                      title: 'warranties.empty_title'.tr(),
                      subtitle: 'warranties.empty_body'.tr(),
                    )
                  else
                    for (final w in warranties) ...[
                      _buildWarrantyItem(context, w, scheme, textTheme),
                      const SizedBox(height: AppConstants.space16),
                    ],
                  Text(
                    'warranties.add_hint'.tr(),
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppConstants.space12),
                  MainButton(
                    label: 'warranties.open_history'.tr(),
                    onPressed: () => pushTo(
                      context,
                      Routes.maintenanceHistoryPath(vehicleId),
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

  Widget _buildWarrantyItem(
    BuildContext context,
    WarrantyModel w,
    ColorScheme scheme,
    TextTheme textTheme,
  ) {
    final subtitleParts = <String>[
      if (w.remainingDays >= 0)
        '${w.remainingDays} ${'warranties.days_left'.tr()}'
      else
        '${'warranties.expired_on'.tr()} ${w.expirationDate}',
      if (w.provider != null && w.provider!.trim().isNotEmpty)
        w.provider!.trim(),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StatusChip(label: _chipLabel(w.status), type: _chipType(w.status)),
        const SizedBox(height: AppConstants.space8),
        Material(
          color: scheme.surface,
          borderRadius: AppConstants.borderRadius20,
          child: InkWell(
            onTap: () async {
              final changed = await pushTo<bool>(
                context,
                Routes.warrantyDetailPath(vehicleId, w.maintenanceRecordId),
                extra: {'itemName': w.itemName, 'isShared': isShared},
              );
              if (changed == true && context.mounted) {
                context.read<WarrantyCubit>().loadWarranties(vehicleId);
              }
            },
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
                          '${w.itemName} · ${w.expirationDate}',
                          style: textTheme.titleLarge?.copyWith(
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppConstants.space8),
                        Text(
                          subtitleParts.join(' • '),
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
      ],
    );
  }
}
