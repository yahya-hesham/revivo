import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/functions/extensions.dart';
import '../../../../core/functions/navigations.dart';
import '../../../../core/functions/validations.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../../../../core/widgets/dialogs.dart';
import '../../../../core/widgets/empty_state_card.dart';
import '../../../../core/widgets/main_button.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../data/models/maintenance_models.dart';
import '../cubit/record_maintenance_cubit.dart';
import '../cubit/record_maintenance_state.dart';

/// Handles:
/// - `Record maintenance` (`4:27`) & `Edit maintenance` (`4:136`)
/// - `Next service` (`4:58`)
/// - `Partial save` (`4:240`) when record succeeds but schedule fails
class RecordMaintenanceScreen extends StatefulWidget {
  const RecordMaintenanceScreen({
    super.key,
    required this.vehicleId,
    this.existingRecord,
  });

  final int vehicleId;
  final MaintenanceRecordModel? existingRecord;

  @override
  State<RecordMaintenanceScreen> createState() =>
      _RecordMaintenanceScreenState();
}

class _RecordMaintenanceScreenState extends State<RecordMaintenanceScreen> {
  static const List<({String item, String category})> _quickSuggestions = [
    (item: 'Engine oil change', category: 'Fluids'),
    (item: 'Oil filter', category: 'Filters'),
    (item: 'Air filter', category: 'Filters'),
    (item: 'Front brake pads', category: 'Brakes'),
    (item: 'Battery replacement', category: 'Electrical'),
    (item: 'Spark plugs', category: 'Engine'),
  ];

  final _recordFormKey = GlobalKey<FormState>();
  final _scheduleFormKey = GlobalKey<FormState>();

  late final TextEditingController _itemController;
  late final TextEditingController _categoryController;
  late final TextEditingController _dateController;
  late final TextEditingController _mileageController;
  late final TextEditingController _costController;
  late final TextEditingController _notesController;

  final _intervalKmController = TextEditingController(text: '10000');
  final _intervalMonthsController = TextEditingController();
  final _warningKmController = TextEditingController(text: '1000');
  final _warningDaysController = TextEditingController(text: '30');

  bool get _isEdit => widget.existingRecord != null;

  @override
  void initState() {
    super.initState();
    final r = widget.existingRecord;
    final todayIso = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _itemController = TextEditingController(text: r?.itemName ?? '');
    _categoryController = TextEditingController(text: r?.category ?? '');
    _dateController = TextEditingController(
      text: r?.maintenanceDate ?? todayIso,
    );
    _mileageController = TextEditingController(
      text: r != null ? '${r.mileageKm}' : '',
    );
    _costController = TextEditingController(
      text: r != null ? r.costEgp.toStringAsFixed(2) : '',
    );
    _notesController = TextEditingController(text: r?.notes ?? '');
  }

  @override
  void dispose() {
    _itemController.dispose();
    _categoryController.dispose();
    _dateController.dispose();
    _mileageController.dispose();
    _costController.dispose();
    _notesController.dispose();
    _intervalKmController.dispose();
    _intervalMonthsController.dispose();
    _warningKmController.dispose();
    _warningDaysController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final current = DateTime.tryParse(_dateController.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _submitRecord() {
    FocusScope.of(context).unfocus();
    if (!_recordFormKey.currentState!.validate()) return;

    final request = MaintenanceRequestModel(
      category: _categoryController.text,
      itemName: _itemController.text,
      maintenanceDate: _dateController.text.trim(),
      mileageKm: int.tryParse(_mileageController.text.trim()) ?? 0,
      costEgp: double.tryParse(_costController.text.trim()) ?? 0,
      notes: _notesController.text,
    );

    if (_isEdit) {
      context.read<RecordMaintenanceCubit>().updateRecord(
            vehicleId: widget.vehicleId,
            recordId: widget.existingRecord!.id,
            request: request,
          );
    } else {
      context.read<RecordMaintenanceCubit>().createRecord(
            vehicleId: widget.vehicleId,
            request: request,
          );
    }
  }

  void _submitSchedule() {
    FocusScope.of(context).unfocus();
    if (!_scheduleFormKey.currentState!.validate()) return;

    int? parseOptional(String raw) {
      final t = raw.trim();
      if (t.isEmpty) return null;
      return int.tryParse(t);
    }

    final req = ScheduleRequestModel(
      intervalKm: parseOptional(_intervalKmController.text),
      intervalMonths: parseOptional(_intervalMonthsController.text),
      warningKm: parseOptional(_warningKmController.text),
      warningDays: parseOptional(_warningDaysController.text),
    );
    context.read<RecordMaintenanceCubit>().saveSchedule(
          vehicleId: widget.vehicleId,
          request: req,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            final saved =
                context.read<RecordMaintenanceCubit>().state.savedRecord != null;
            pop(context, saved);
          },
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<RecordMaintenanceCubit, RecordMaintenanceState>(
          listener: (context, state) {
            if (!context.mounted) return;
            if (state.step == 3) {
              showMyDialog(
                context,
                _isEdit
                    ? 'maintenance.updated_toast'.tr()
                    : 'maintenance.saved_toast'.tr(),
                type: DialogType.success,
              );
              pop(context, true);
            }
          },
          builder: (context, state) {
            return switch (state.step) {
              0 => _buildRecordForm(context, state),
              1 => _buildNextServiceStep(context, state),
              2 => _buildPartialSaveStep(context, state),
              _ => const Center(child: CircularProgressIndicator()),
            };
          },
        ),
      ),
    );
  }

  Widget _buildRecordForm(BuildContext context, RecordMaintenanceState state) {
    final scheme = context.colorScheme;
    final textTheme = context.textTheme;

    return SingleChildScrollView(
      padding: AppConstants.paddingScreen,
      child: Form(
        key: _recordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEdit
                  ? 'maintenance.edit_title'.tr()
                  : 'maintenance.record_title'.tr(),
              style: textTheme.headlineLarge?.copyWith(color: scheme.onSurface),
            ),
            const SizedBox(height: AppConstants.space8),
            Text(
              'maintenance.record_subtitle'.tr(),
              style: textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            if (!_isEdit) ...[
              const SizedBox(height: AppConstants.space16),
              Wrap(
                spacing: AppConstants.space8,
                runSpacing: AppConstants.space8,
                children: [
                  for (final s in _quickSuggestions)
                    ActionChip(
                      label: Text(s.item),
                      onPressed: () {
                        _itemController.text = s.item;
                        _categoryController.text = s.category;
                      },
                    ),
                ],
              ),
            ],
            if (state.errorMessage != null && state.fieldErrors.isEmpty) ...[
              const SizedBox(height: AppConstants.space16),
              EmptyStateCard(
                title: 'garage.error_title'.tr(),
                subtitle: state.errorMessage!,
              ),
            ],
            const SizedBox(height: AppConstants.space16),
            CustomTextFormField(
              label: 'maintenance.item_label'.tr(),
              hintText: 'Engine oil change',
              controller: _itemController,
              enabled: !state.isSubmitting,
              textInputAction: TextInputAction.next,
              errorText: state.fieldError('itemName'),
              validator: (v) => AppValidations.requiredText(
                v,
                fieldName: 'maintenance.item_label'.tr(),
              ),
            ),
            const SizedBox(height: AppConstants.space16),
            CustomTextFormField(
              label: 'maintenance.category_label'.tr(),
              hintText: 'Fluids',
              controller: _categoryController,
              enabled: !state.isSubmitting,
              textInputAction: TextInputAction.next,
              errorText: state.fieldError('category'),
              validator: (v) => AppValidations.requiredText(
                v,
                fieldName: 'maintenance.category_label'.tr(),
              ),
            ),
            const SizedBox(height: AppConstants.space8),
            Text(
              'maintenance.item_hint'.tr(),
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppConstants.space16),
            CustomTextFormField(
              label: 'maintenance.date_label'.tr(),
              controller: _dateController,
              readOnly: true,
              enabled: !state.isSubmitting,
              errorText: state.fieldError('maintenanceDate'),
              onTap: _pickDate,
              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
            ),
            const SizedBox(height: AppConstants.space16),
            CustomTextFormField(
              label: 'maintenance.mileage_label'.tr(),
              hintText: '48200',
              controller: _mileageController,
              enabled: !state.isSubmitting,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              errorText: state.fieldError('mileageKm'),
              validator: AppValidations.mileage,
            ),
            const SizedBox(height: AppConstants.space16),
            CustomTextFormField(
              label: 'maintenance.cost_label'.tr(),
              hintText: '1450.00',
              controller: _costController,
              enabled: !state.isSubmitting,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              errorText: state.fieldError('costEgp'),
              validator: AppValidations.costEgp,
            ),
            const SizedBox(height: AppConstants.space16),
            CustomTextFormField(
              label: 'maintenance.notes_label'.tr(),
              hintText: 'maintenance.notes_hint'.tr(),
              controller: _notesController,
              enabled: !state.isSubmitting,
              maxLines: 3,
              errorText: state.fieldError('notes'),
            ),
            const SizedBox(height: AppConstants.space16),
            MainButton(
              label: _isEdit
                  ? 'garage.save_changes'.tr()
                  : 'maintenance.save_submit'.tr(),
              isLoading: state.isSubmitting,
              onPressed: _submitRecord,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextServiceStep(
    BuildContext context,
    RecordMaintenanceState state,
  ) {
    final scheme = context.colorScheme;
    final textTheme = context.textTheme;
    final record = state.savedRecord;
    final egpFormat = NumberFormat('#,##0.##');

    return SingleChildScrollView(
      padding: AppConstants.paddingScreen,
      child: Form(
        key: _scheduleFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'maintenance.next_service_title'.tr(),
              style: textTheme.headlineLarge?.copyWith(color: scheme.onSurface),
            ),
            const SizedBox(height: AppConstants.space8),
            Text(
              record != null
                  ? '${record.itemName} · EGP ${egpFormat.format(record.costEgp)}'
                  : '',
              style: textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppConstants.space12),
            StatusChip(
              label: 'garage.status_on_track'.tr(),
              type: StatusChipType.onTrack,
            ),
            const SizedBox(height: AppConstants.space16),
            EmptyStateCard(
              title: 'maintenance.plan_next_card_title'.tr(),
              subtitle: 'maintenance.plan_next_card_body'.tr(),
            ),
            const SizedBox(height: AppConstants.space16),
            CustomTextFormField(
              label: 'maintenance.interval_km_label'.tr(),
              hintText: '10000',
              controller: _intervalKmController,
              enabled: !state.isSubmitting,
              keyboardType: TextInputType.number,
              errorText: state.fieldError('intervalKm'),
            ),
            const SizedBox(height: AppConstants.space16),
            CustomTextFormField(
              label: 'maintenance.interval_months_label'.tr(),
              hintText: '6',
              controller: _intervalMonthsController,
              enabled: !state.isSubmitting,
              keyboardType: TextInputType.number,
              errorText: state.fieldError('intervalMonths'),
            ),
            const SizedBox(height: AppConstants.space16),
            CustomTextFormField(
              label: 'maintenance.warning_km_label'.tr(),
              hintText: '1000',
              controller: _warningKmController,
              enabled: !state.isSubmitting,
              keyboardType: TextInputType.number,
              errorText: state.fieldError('warningKm'),
            ),
            const SizedBox(height: AppConstants.space16),
            CustomTextFormField(
              label: 'maintenance.warning_days_label'.tr(),
              hintText: '30',
              controller: _warningDaysController,
              enabled: !state.isSubmitting,
              keyboardType: TextInputType.number,
              errorText: state.fieldError('warningDays'),
            ),
            const SizedBox(height: AppConstants.space16),
            MainButton(
              label: 'maintenance.set_next_service'.tr(),
              isLoading: state.isSubmitting,
              onPressed: _submitSchedule,
            ),
            const SizedBox(height: AppConstants.space12),
            MainButton(
              label: 'maintenance.no_recurring_schedule'.tr(),
              variant: MainButtonVariant.secondary,
              onPressed: state.isSubmitting
                  ? null
                  : () => context.read<RecordMaintenanceCubit>().skipSchedule(),
            ),
            const SizedBox(height: AppConstants.space12),
            Text(
              'maintenance.schedule_warranty_note'.tr(),
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartialSaveStep(
    BuildContext context,
    RecordMaintenanceState state,
  ) {
    final scheme = context.colorScheme;
    final textTheme = context.textTheme;
    final record = state.savedRecord;
    final egpFormat = NumberFormat('#,##0.##');

    return ListView(
      padding: AppConstants.paddingScreen,
      children: [
        Text(
          'maintenance.partial_title'.tr(),
          style: textTheme.headlineLarge?.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: AppConstants.space8),
        Text(
          'maintenance.partial_subtitle'.tr(),
          style: textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppConstants.space16),
        if (record != null)
          EmptyStateCard(
            title: '${record.itemName} · ${'maintenance.saved_badge'.tr()}',
            subtitle:
                '${record.maintenanceDate} • EGP ${egpFormat.format(record.costEgp)}',
          ),
        const SizedBox(height: AppConstants.space12),
        EmptyStateCard(
          title: 'maintenance.partial_failed_title'.tr(),
          subtitle:
              state.errorMessage ?? 'maintenance.partial_failed_body'.tr(),
        ),
        const SizedBox(height: AppConstants.space16),
        MainButton(
          label: 'maintenance.retry_schedule'.tr(),
          isLoading: state.isSubmitting,
          onPressed: () => context
              .read<RecordMaintenanceCubit>()
              .retrySchedule(widget.vehicleId),
        ),
        const SizedBox(height: AppConstants.space12),
        MainButton(
          label: 'maintenance.return_to_car'.tr(),
          variant: MainButtonVariant.secondary,
          onPressed: () => pop(context, true),
        ),
      ],
    );
  }
}
