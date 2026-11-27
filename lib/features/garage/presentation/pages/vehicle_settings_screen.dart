import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/functions/extensions.dart';
import '../../../../core/functions/navigations.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../../../../core/widgets/dialogs.dart';
import '../../../../core/widgets/empty_state_card.dart';
import '../../../../core/widgets/main_button.dart';
import '../../data/models/vehicle_model.dart';
import '../cubit/vehicle_dashboard_cubit.dart';
import '../cubit/vehicle_dashboard_state.dart';

/// Owner-only Vehicle settings screen matching Figma `Vehicle settings` (`3:326`).
class VehicleSettingsScreen extends StatefulWidget {
  const VehicleSettingsScreen({super.key, required this.vehicle});

  final VehicleModel vehicle;

  @override
  State<VehicleSettingsScreen> createState() => _VehicleSettingsScreenState();
}

class _VehicleSettingsScreenState extends State<VehicleSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nicknameController;
  late final TextEditingController _yearController;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(
      text: widget.vehicle.nickname ?? '',
    );
    _yearController = TextEditingController(text: '${widget.vehicle.year}');
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final year = int.tryParse(_yearController.text.trim()) ?? widget.vehicle.year;
    context.read<VehicleDashboardCubit>().updateVehicle(
          existing: widget.vehicle,
          year: year,
          nickname: _nicknameController.text,
        );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('garage.delete_confirm_title'.tr()),
        content: Text('garage.delete_confirm_body'.tr()),
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
    if (confirmed == true && mounted) {
      context.read<VehicleDashboardCubit>().deleteVehicle(widget.vehicle.id);
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
        child: BlocConsumer<VehicleDashboardCubit, VehicleDashboardState>(
          listener: (context, state) {
            if (!context.mounted) return;
            if (state is VehicleUpdatedSuccess) {
              showMyDialog(
                context,
                'garage.vehicle_updated'.tr(),
                type: DialogType.success,
              );
              pop(context, 'updated');
            } else if (state is VehicleDeletedSuccess) {
              showMyDialog(
                context,
                'garage.vehicle_deleted'.tr(),
                type: DialogType.success,
              );
              pop(context, 'deleted');
            } else if (state is VehicleDashboardError &&
                state.fieldErrors.isEmpty) {
              showMyDialog(context, state.message, type: DialogType.error);
            }
          },
          builder: (context, state) {
            final isLoading = state is VehicleActionLoading;
            final errorState = state is VehicleDashboardError ? state : null;
            final maxYear = DateTime.now().toUtc().year + 1;

            return SingleChildScrollView(
              padding: AppConstants.paddingScreen,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'garage.vehicle_details_title'.tr(),
                      style: textTheme.headlineLarge?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppConstants.space8),
                    Text(
                      '${widget.vehicle.catalogTitle} · ${'garage.owner_label'.tr()}',
                      style: textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppConstants.space16),
                    CustomTextFormField(
                      label: 'garage.nickname_label'.tr(),
                      hintText: 'garage.nickname_hint'.tr(),
                      controller: _nicknameController,
                      enabled: !isLoading,
                      textInputAction: TextInputAction.next,
                      errorText: errorState?.fieldError('nickname'),
                      validator: (v) {
                        if ((v?.trim().length ?? 0) > 100) {
                          return 'garage.nickname_too_long'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.space16),
                    CustomTextFormField(
                      label: 'garage.year_label'.tr(),
                      hintText: '2022',
                      controller: _yearController,
                      enabled: !isLoading,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      errorText: errorState?.fieldError('year'),
                      validator: (v) {
                        final parsed = int.tryParse(v?.trim() ?? '');
                        if (parsed == null || parsed < 1886 || parsed > maxYear) {
                          return 'garage.year_invalid'.tr(
                            namedArgs: {'max': '$maxYear'},
                          );
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _save(),
                    ),
                    const SizedBox(height: AppConstants.space16),
                    Text(
                      'garage.mileage_update_note'.tr(),
                      style: textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppConstants.space16),
                    MainButton(
                      label: 'garage.save_changes'.tr(),
                      isLoading: isLoading,
                      onPressed: _save,
                    ),
                    const SizedBox(height: AppConstants.space12),
                    MainButton(
                      label: 'garage.delete_vehicle'.tr(),
                      variant: MainButtonVariant.danger,
                      onPressed: isLoading ? null : _confirmDelete,
                    ),
                    const SizedBox(height: AppConstants.space16),
                    EmptyStateCard(
                      title: 'garage.history_warning_title'.tr(),
                      subtitle: 'garage.history_warning_body'.tr(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
