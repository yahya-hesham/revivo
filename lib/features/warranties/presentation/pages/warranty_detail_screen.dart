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
import '../../../../core/widgets/shimmer/app_shimmer.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../data/models/warranty_models.dart';
import '../cubit/warranty_cubit.dart';
import '../cubit/warranty_state.dart';

/// Warranty details screen matching Figma `Warranty details` (`4:185`).
class WarrantyDetailScreen extends StatelessWidget {
  const WarrantyDetailScreen({
    super.key,
    required this.vehicleId,
    required this.recordId,
    this.itemName,
    this.isShared = false,
  });

  final int vehicleId;
  final int recordId;
  final String? itemName;
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

  Future<void> _openForm(BuildContext context, WarrantyModel? existing) async {
    final saved = await pushTo<bool>(
      context,
      Routes.warrantyFormPath(vehicleId, recordId),
      extra: {'warranty': existing, 'itemName': itemName ?? existing?.itemName},
    );
    if (saved == true && context.mounted) {
      context.read<WarrantyCubit>().loadRecordWarranty(
            vehicleId: vehicleId,
            recordId: recordId,
          );
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('warranties.delete_confirm_title'.tr()),
        content: Text('warranties.delete_confirm_body'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('common.delete'.tr()),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<WarrantyCubit>().deleteWarranty(
            vehicleId: vehicleId,
            recordId: recordId,
          );
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
        child: BlocConsumer<WarrantyCubit, WarrantyState>(
          listener: (context, state) {
            if (!context.mounted) return;
            if (state is WarrantyDeletedSuccess) {
              showMyDialog(
                context,
                'warranties.deleted_toast'.tr(),
                type: DialogType.success,
              );
              pop(context, true);
            } else if (state is WarrantyError) {
              showMyDialog(context, state.message, type: DialogType.error);
            }
          },
          builder: (context, state) {
            if (state is WarrantyLoading ||
                state is WarrantyInitial ||
                state is WarrantyActionLoading) {
              return ListView(
                padding: AppConstants.paddingScreen,
                children: const [
                  AppShimmerBox(height: 32, width: 180),
                  SizedBox(height: AppConstants.space16),
                  AppShimmerBox(height: 110),
                  SizedBox(height: AppConstants.space16),
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
                      onPressed: () => context
                          .read<WarrantyCubit>()
                          .loadRecordWarranty(
                            vehicleId: vehicleId,
                            recordId: recordId,
                          ),
                    ),
                  ],
                ),
              );
            }

            final warranty = (state as WarrantyDetailLoaded).warranty;
            if (warranty == null) {
              return Padding(
                padding: AppConstants.paddingScreen,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemName ?? 'warranties.title_short'.tr(),
                      style: textTheme.headlineLarge?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppConstants.space16),
                    EmptyStateCard(
                      title: 'warranties.no_record_warranty_title'.tr(),
                      subtitle: 'warranties.no_record_warranty_body'.tr(),
                    ),
                    if (!isShared) ...[
                      const SizedBox(height: AppConstants.space16),
                      MainButton(
                        label: 'warranties.add_warranty'.tr(),
                        onPressed: () => _openForm(context, null),
                      ),
                    ],
                  ],
                ),
              );
            }

            final detailsLines = <String>[
              if (warranty.brand != null && warranty.brand!.isNotEmpty)
                '${'warranties.brand_label'.tr()}: ${warranty.brand}',
              '${'warranties.coverage_label'.tr()}: ${warranty.durationMonths} ${'warranties.months_unit'.tr()}',
              '${'warranties.start_label'.tr()}: ${warranty.startDate}',
              '${'warranties.remind_before_label'.tr()}: ${warranty.warningDays} ${'warranties.days_unit'.tr()}',
              if (warranty.notes != null && warranty.notes!.isNotEmpty)
                warranty.notes!,
            ];

            return ListView(
              padding: AppConstants.paddingScreen,
              children: [
                Text(
                  '${warranty.itemName} ${'warranties.warranty_suffix'.tr()}',
                  style: textTheme.headlineLarge?.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppConstants.space8),
                Text(
                  '${warranty.itemName} · ${warranty.startDate}',
                  style: textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppConstants.space12),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: StatusChip(
                    label: _chipLabel(warranty.status),
                    type: _chipType(warranty.status),
                  ),
                ),
                const SizedBox(height: AppConstants.space16),
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
                        warranty.remainingDays >= 0
                            ? '${warranty.remainingDays} ${'warranties.days_left'.tr()}'
                            : 'warranties.status_expired'.tr(),
                        style: textTheme.displayLarge?.copyWith(
                          color: AppColors.onBrand,
                        ),
                      ),
                      const SizedBox(height: AppConstants.space8),
                      Text(
                        '${'warranties.expires_label'.tr()} ${warranty.expirationDate}',
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.onBrand.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (warranty.provider != null &&
                    warranty.provider!.trim().isNotEmpty) ...[
                  const SizedBox(height: AppConstants.space16),
                  EmptyStateCard(
                    title: warranty.provider!,
                    subtitle: 'warranties.provider_label'.tr(),
                  ),
                ],
                const SizedBox(height: AppConstants.space16),
                Text(
                  detailsLines.join('\n'),
                  style: textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppConstants.space16),
                if (!isShared) ...[
                  MainButton(
                    label: 'warranties.edit_warranty'.tr(),
                    onPressed: () => _openForm(context, warranty),
                  ),
                  const SizedBox(height: AppConstants.space12),
                  MainButton(
                    label: 'warranties.remove_warranty'.tr(),
                    variant: MainButtonVariant.danger,
                    onPressed: () => _confirmDelete(context),
                  ),
                  const SizedBox(height: AppConstants.space12),
                ],
                MainButton(
                  label: 'warranties.back_to_warranties'.tr(),
                  variant: MainButtonVariant.secondary,
                  onPressed: () => pop(context, true),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
