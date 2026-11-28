import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/functions/extensions.dart';
import '../../../../core/functions/navigations.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../../../../core/widgets/dialogs.dart';
import '../../../../core/widgets/main_button.dart';
import '../../data/models/warranty_models.dart';
import '../cubit/warranty_cubit.dart';
import '../cubit/warranty_state.dart';

/// Create or edit warranty form matching Figma `Warranty form` (`4:210`).
class WarrantyFormScreen extends StatefulWidget {
  const WarrantyFormScreen({
    super.key,
    required this.vehicleId,
    required this.recordId,
    this.existingWarranty,
    this.itemName,
  });

  final int vehicleId;
  final int recordId;
  final WarrantyModel? existingWarranty;
  final String? itemName;

  @override
  State<WarrantyFormScreen> createState() => _WarrantyFormScreenState();
}

class _WarrantyFormScreenState extends State<WarrantyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _durationController;
  late final TextEditingController _startDateController;
  late final TextEditingController _providerController;
  late final TextEditingController _brandController;
  late final TextEditingController _warningDaysController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final w = widget.existingWarranty;
    _durationController = TextEditingController(
      text: w != null ? '${w.durationMonths}' : '12',
    );
    _startDateController = TextEditingController(text: w?.startDate ?? '');
    _providerController = TextEditingController(text: w?.provider ?? '');
    _brandController = TextEditingController(text: w?.brand ?? '');
    _warningDaysController = TextEditingController(
      text: w != null ? '${w.warningDays}' : '30',
    );
    _notesController = TextEditingController(text: w?.notes ?? '');
  }

  @override
  void dispose() {
    _durationController.dispose();
    _startDateController.dispose();
    _providerController.dispose();
    _brandController.dispose();
    _warningDaysController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final initial =
        DateTime.tryParse(_startDateController.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      _startDateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final duration = int.tryParse(_durationController.text.trim()) ?? 12;
    final warningDays = int.tryParse(_warningDaysController.text.trim());

    context.read<WarrantyCubit>().saveWarranty(
          vehicleId: widget.vehicleId,
          recordId: widget.recordId,
          request: WarrantyRequestModel(
            durationMonths: duration,
            startDate: _startDateController.text.trim().isEmpty
                ? null
                : _startDateController.text.trim(),
            warningDays: warningDays,
            provider: _providerController.text,
            brand: _brandController.text,
            notes: _notesController.text,
          ),
        );
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
        child: BlocConsumer<WarrantyCubit, WarrantyState>(
          listener: (context, state) {
            if (!context.mounted) return;
            if (state is WarrantySavedSuccess) {
              showMyDialog(
                context,
                'warranties.saved_toast'.tr(),
                type: DialogType.success,
              );
              pop(context, true);
            } else if (state is WarrantyError && state.fieldErrors.isEmpty) {
              showMyDialog(context, state.message, type: DialogType.error);
            }
          },
          builder: (context, state) {
            final isLoading = state is WarrantyActionLoading;
            final errorState = state is WarrantyError ? state : null;

            return SingleChildScrollView(
              padding: AppConstants.paddingScreen,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'warranties.form_title'.tr(),
                      style: textTheme.headlineLarge?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppConstants.space8),
                    Text(
                      widget.itemName != null
                          ? 'warranties.form_subtitle_item'.tr(
                              namedArgs: {'item': widget.itemName!},
                            )
                          : 'warranties.form_subtitle'.tr(),
                      style: textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppConstants.space16),
                    CustomTextFormField(
                      label: 'warranties.duration_label'.tr(),
                      hintText: '12',
                      controller: _durationController,
                      enabled: !isLoading,
                      keyboardType: TextInputType.number,
                      errorText: errorState?.fieldError('durationMonths'),
                      validator: (v) {
                        final parsed = int.tryParse(v?.trim() ?? '');
                        if (parsed == null || parsed < 1 || parsed > 1200) {
                          return 'warranties.duration_invalid'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.space16),
                    CustomTextFormField(
                      label: 'warranties.start_date_optional_label'.tr(),
                      hintText: 'YYYY-MM-DD',
                      controller: _startDateController,
                      readOnly: true,
                      enabled: !isLoading,
                      errorText: errorState?.fieldError('startDate'),
                      onTap: _pickStartDate,
                      suffixIcon: const Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: AppConstants.space16),
                    CustomTextFormField(
                      label: 'warranties.provider_optional_label'.tr(),
                      hintText: 'Nile Auto Parts',
                      controller: _providerController,
                      enabled: !isLoading,
                      errorText: errorState?.fieldError('provider'),
                    ),
                    const SizedBox(height: AppConstants.space16),
                    CustomTextFormField(
                      label: 'warranties.brand_optional_label'.tr(),
                      hintText: 'Bosch',
                      controller: _brandController,
                      enabled: !isLoading,
                      errorText: errorState?.fieldError('brand'),
                    ),
                    const SizedBox(height: AppConstants.space16),
                    CustomTextFormField(
                      label: 'warranties.warning_days_label'.tr(),
                      hintText: '30',
                      controller: _warningDaysController,
                      enabled: !isLoading,
                      keyboardType: TextInputType.number,
                      errorText: errorState?.fieldError('warningDays'),
                    ),
                    const SizedBox(height: AppConstants.space16),
                    CustomTextFormField(
                      label: 'maintenance.notes_label'.tr(),
                      hintText: 'warranties.notes_hint'.tr(),
                      controller: _notesController,
                      enabled: !isLoading,
                      maxLines: 3,
                      errorText: errorState?.fieldError('notes'),
                    ),
                    const SizedBox(height: AppConstants.space16),
                    MainButton(
                      label: 'warranties.save_submit'.tr(),
                      isLoading: isLoading,
                      onPressed: _submit,
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
