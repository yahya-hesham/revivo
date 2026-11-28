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
import '../../data/models/maintenance_models.dart';
import '../cubit/record_maintenance_cubit.dart';
import '../cubit/record_maintenance_state.dart';

/// Maintenance record detail screen matching Figma `Maintenance details` (`4:110`).
class MaintenanceDetailScreen extends StatelessWidget {
  const MaintenanceDetailScreen({
    super.key,
    required this.record,
    this.isShared = false,
  });

  final MaintenanceRecordModel record;
  final bool isShared;

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('maintenance.delete_confirm_title'.tr()),
        content: Text('maintenance.delete_confirm_body'.tr()),
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
      context.read<RecordMaintenanceCubit>().deleteRecord(
            vehicleId: record.vehicleId,
            recordId: record.id,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final textTheme = context.textTheme;
    final kmFormat = NumberFormat.decimalPattern();
    final egpFormat = NumberFormat('#,##0.##');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => pop(context),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<RecordMaintenanceCubit, RecordMaintenanceState>(
          listener: (context, state) {
            if (!context.mounted) return;
            if (state.isDeleted) {
              showMyDialog(
                context,
                'maintenance.deleted_toast'.tr(),
                type: DialogType.success,
              );
              pop(context, true);
            } else if (state.errorMessage != null) {
              showMyDialog(context, state.errorMessage!, type: DialogType.error);
            }
          },
          builder: (context, state) {
            return ListView(
              padding: AppConstants.paddingScreen,
              children: [
                Text(
                  record.itemName,
                  style: textTheme.headlineLarge?.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppConstants.space8),
                Text(
                  '${record.category} · ${record.maintenanceDate}',
                  style: textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
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
                        'EGP ${egpFormat.format(record.costEgp)}',
                        style: textTheme.displayLarge?.copyWith(
                          color: AppColors.onBrand,
                        ),
                      ),
                      const SizedBox(height: AppConstants.space8),
                      Text(
                        'maintenance.service_cost'.tr(),
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.onBrand.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.space16),
                EmptyStateCard(
                  title:
                      '${kmFormat.format(record.mileageKm)} ${'garage.km_unit'.tr()}',
                  subtitle: 'maintenance.mileage_at_service'.tr(),
                ),
                if (record.notes != null && record.notes!.trim().isNotEmpty) ...[
                  const SizedBox(height: AppConstants.space16),
                  Text(
                    record.notes!,
                    style: textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: AppConstants.space16),
                if (!isShared) ...[
                  MainButton(
                    label: 'maintenance.edit_record'.tr(),
                    onPressed: state.isSubmitting
                        ? null
                        : () async {
                            final updated = await pushTo<bool>(
                              context,
                              Routes.editMaintenancePath(
                                record.vehicleId,
                                record.id,
                              ),
                              extra: record,
                            );
                            if (updated == true && context.mounted) {
                              pop(context, true);
                            }
                          },
                  ),
                  const SizedBox(height: AppConstants.space12),
                  MainButton(
                    label: 'warranties.add_or_view'.tr(),
                    variant: MainButtonVariant.secondary,
                    onPressed: state.isSubmitting
                        ? null
                        : () => pushTo(
                              context,
                              Routes.warrantyDetailPath(
                                record.vehicleId,
                                record.id,
                              ),
                              extra: {
                                'itemName': record.itemName,
                                'isShared': isShared,
                              },
                            ),
                  ),
                  const SizedBox(height: AppConstants.space12),
                  MainButton(
                    label: 'maintenance.delete_record'.tr(),
                    variant: MainButtonVariant.danger,
                    isLoading: state.isSubmitting,
                    onPressed: () => _confirmDelete(context),
                  ),
                ] else
                  MainButton(
                    label: 'warranties.view_warranty'.tr(),
                    variant: MainButtonVariant.secondary,
                    onPressed: () => pushTo(
                      context,
                      Routes.warrantyDetailPath(record.vehicleId, record.id),
                      extra: {'itemName': record.itemName, 'isShared': true},
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
