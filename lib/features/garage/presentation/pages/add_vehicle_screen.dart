import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/functions/extensions.dart';
import '../../../../core/functions/navigations.dart';
import '../../../../core/functions/validations.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../../../../core/widgets/empty_state_card.dart';
import '../../../../core/widgets/main_button.dart';
import '../../../../core/widgets/shimmer/app_shimmer.dart';
import '../cubit/add_vehicle_cubit.dart';
import '../cubit/add_vehicle_state.dart';
import '../widgets/vehicle_hero_card.dart';

/// 3-step Add Vehicle wizard + confirmation screen matching Figma:
/// - Step 0: `Add car` (`3:205`)
/// - Step 1: `Model and year` (`3:228`)
/// - Step 2: `Car details` (`3:250`)
/// - Step 3: `Car added` (`3:271`)
class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _detailsFormKey = GlobalKey<FormState>();
  final _makeSearchController = TextEditingController();
  final _modelSearchController = TextEditingController();
  final _mileageController = TextEditingController();
  final _nicknameController = TextEditingController();

  @override
  void dispose() {
    _makeSearchController.dispose();
    _modelSearchController.dispose();
    _mileageController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _submitDetails() {
    FocusScope.of(context).unfocus();
    if (!_detailsFormKey.currentState!.validate()) return;
    final mileage = int.tryParse(_mileageController.text.trim()) ?? 0;
    context.read<AddVehicleCubit>().submitVehicle(
          currentMileageKm: mileage,
          nickname: _nicknameController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddVehicleCubit, AddVehicleState>(
      builder: (context, state) {
        return PopScope(
          canPop: state.step == 0 || state.step == 3,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && state.step > 0 && state.step < 3) {
              context.read<AddVehicleCubit>().goBackStep();
            }
          },
          child: Scaffold(
            appBar: state.step < 3
                ? AppBar(
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () {
                        if (state.step == 0) {
                          pop(context, false);
                        } else {
                          context.read<AddVehicleCubit>().goBackStep();
                        }
                      },
                    ),
                  )
                : null,
            body: SafeArea(
              child: switch (state.step) {
                0 => _buildStepMake(context, state),
                1 => _buildStepModelYear(context, state),
                2 => _buildStepDetails(context, state),
                _ => _buildStepAdded(context, state),
              },
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Step 1 of 3 — Choose Make (`3:205`)
  // ---------------------------------------------------------------------------
  Widget _buildStepMake(BuildContext context, AddVehicleState state) {
    final scheme = context.colorScheme;
    final textTheme = context.textTheme;

    return ListView(
      padding: AppConstants.paddingScreen,
      children: [
        Text(
          'garage.add_make_title'.tr(),
          style: textTheme.headlineLarge?.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: AppConstants.space16),
        Text(
          'garage.add_step1_subtitle'.tr(),
          style: textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppConstants.space16),
        CustomTextFormField(
          label: 'garage.search_makes_label'.tr(),
          hintText: 'garage.search_makes_hint'.tr(),
          controller: _makeSearchController,
          textInputAction: TextInputAction.search,
          onChanged: (q) => context.read<AddVehicleCubit>().loadMakes(search: q),
        ),
        const SizedBox(height: AppConstants.space16),
        if (state.isLoadingMakes) ...[
          const AppShimmerBox(height: 84),
          const SizedBox(height: AppConstants.space12),
          const AppShimmerBox(height: 84),
        ] else if (state.errorMessage != null) ...[
          EmptyStateCard(
            title: 'garage.error_title'.tr(),
            subtitle: state.errorMessage!,
          ),
          const SizedBox(height: AppConstants.space16),
          MainButton(
            label: 'common.retry'.tr(),
            onPressed: () => context
                .read<AddVehicleCubit>()
                .loadMakes(search: _makeSearchController.text),
          ),
        ] else if (state.makes.isEmpty) ...[
          EmptyStateCard(
            title: 'garage.no_makes_title'.tr(),
            subtitle: 'garage.no_makes_subtitle'.tr(),
          ),
        ] else ...[
          for (final make in state.makes) ...[
            _CatalogOptionCard(
              title: make.name,
              subtitle: 'garage.select_make'.tr(),
              onTap: () {
                _modelSearchController.clear();
                context.read<AddVehicleCubit>().selectMake(make);
              },
            ),
            const SizedBox(height: AppConstants.space12),
          ],
        ],
        const SizedBox(height: AppConstants.space8),
        Text(
          'garage.catalog_caption'.tr(),
          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Step 2 of 3 — Choose Model & Year (`3:228`)
  // ---------------------------------------------------------------------------
  Widget _buildStepModelYear(BuildContext context, AddVehicleState state) {
    final scheme = context.colorScheme;
    final textTheme = context.textTheme;
    final makeName = state.selectedMake?.name ?? '';

    return ListView(
      padding: AppConstants.paddingScreen,
      children: [
        Text(
          'garage.add_model_title'.tr(namedArgs: {'make': makeName}),
          style: textTheme.headlineLarge?.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: AppConstants.space16),
        Text(
          'garage.add_step2_subtitle'.tr(),
          style: textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppConstants.space16),
        CustomTextFormField(
          label: 'garage.model_label'.tr(),
          hintText: 'garage.model_hint'.tr(),
          controller: _modelSearchController,
          textInputAction: TextInputAction.search,
          onChanged: (q) =>
              context.read<AddVehicleCubit>().searchModels(search: q),
        ),
        const SizedBox(height: AppConstants.space16),
        if (state.isLoadingModels) ...[
          const AppShimmerBox(height: 84),
          const SizedBox(height: AppConstants.space12),
          const AppShimmerBox(height: 84),
        ] else if (state.models.isEmpty) ...[
          EmptyStateCard(
            title: 'garage.no_models_title'.tr(),
            subtitle: 'garage.no_models_subtitle'.tr(),
          ),
        ] else ...[
          for (final model in state.models) ...[
            _CatalogOptionCard(
              title: model.name,
              subtitle: makeName,
              isSelected: state.selectedModel?.id == model.id,
              onTap: () => context.read<AddVehicleCubit>().selectModel(model),
            ),
            const SizedBox(height: AppConstants.space12),
          ],
        ],
        if (state.selectedModel != null) ...[
          const SizedBox(height: AppConstants.space8),
          Text(
            'garage.year_label'.tr(),
            style: textTheme.labelLarge?.copyWith(color: scheme.onSurface),
          ),
          const SizedBox(height: AppConstants.space8),
          if (state.isLoadingYears)
            const AppShimmerBox(height: 56)
          else if (state.years.isEmpty)
            EmptyStateCard(
              title: 'garage.no_years_title'.tr(),
              subtitle: 'garage.no_years_subtitle'.tr(),
            )
          else
            Wrap(
              spacing: AppConstants.space8,
              runSpacing: AppConstants.space8,
              children: [
                for (final year in state.years)
                  ChoiceChip(
                    label: Text('$year'),
                    selected: state.selectedYear == year,
                    onSelected: (_) =>
                        context.read<AddVehicleCubit>().selectYear(year),
                  ),
              ],
            ),
          const SizedBox(height: AppConstants.space12),
          Text(
            'garage.year_caption'.tr(),
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppConstants.space16),
          MainButton(
            label: 'garage.continue_cta'.tr(),
            onPressed: state.selectedYear != null
                ? () => context.read<AddVehicleCubit>().continueToDetails()
                : null,
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Step 3 of 3 — Car details (`3:250`)
  // ---------------------------------------------------------------------------
  Widget _buildStepDetails(BuildContext context, AddVehicleState state) {
    final scheme = context.colorScheme;
    final textTheme = context.textTheme;

    return SingleChildScrollView(
      padding: AppConstants.paddingScreen,
      child: Form(
        key: _detailsFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'garage.add_details_title'.tr(),
              style: textTheme.headlineLarge?.copyWith(color: scheme.onSurface),
            ),
            const SizedBox(height: AppConstants.space16),
            Text(
              'garage.add_step3_subtitle'.tr(),
              style: textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppConstants.space16),
            VehicleHeroCard(
              carImage: state.carImage,
              isLoading: state.isLoadingImage,
            ),
            if (state.errorMessage != null && state.fieldErrors.isEmpty) ...[
              const SizedBox(height: AppConstants.space16),
              EmptyStateCard(
                title: 'garage.error_title'.tr(),
                subtitle: state.errorMessage!,
              ),
            ],
            const SizedBox(height: AppConstants.space16),
            CustomTextFormField(
              label: 'garage.mileage_label'.tr(),
              hintText: '48200',
              controller: _mileageController,
              enabled: !state.isSubmitting,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              errorText: state.fieldError('currentMileageKm'),
              validator: AppValidations.mileage,
            ),
            const SizedBox(height: AppConstants.space16),
            CustomTextFormField(
              label: 'garage.nickname_optional_label'.tr(),
              hintText: 'garage.nickname_hint'.tr(),
              controller: _nicknameController,
              enabled: !state.isSubmitting,
              textInputAction: TextInputAction.done,
              errorText: state.fieldError('nickname'),
              validator: (v) {
                final trimmed = v?.trim() ?? '';
                if (trimmed.length > 100) {
                  return 'garage.nickname_too_long'.tr();
                }
                return null;
              },
              onFieldSubmitted: (_) => _submitDetails(),
            ),
            const SizedBox(height: AppConstants.space16),
            MainButton(
              label: 'garage.add_car_submit'.tr(),
              isLoading: state.isSubmitting,
              onPressed: _submitDetails,
            ),
            const SizedBox(height: AppConstants.space12),
            Text(
              'garage.illustrative_disclaimer'.tr(),
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Confirmation — Car added (`3:271`)
  // ---------------------------------------------------------------------------
  Widget _buildStepAdded(BuildContext context, AddVehicleState state) {
    final scheme = context.colorScheme;
    final textTheme = context.textTheme;
    final vehicle = state.createdVehicle;
    final carName = vehicle?.catalogTitle ?? '';

    return ListView(
      padding: AppConstants.paddingScreen,
      children: [
        Text(
          'garage.car_added_title'.tr(),
          style: textTheme.headlineLarge?.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: AppConstants.space16),
        Text(
          'garage.car_added_subtitle'.tr(namedArgs: {'car': carName}),
          style: textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppConstants.space16),
        VehicleHeroCard(
          imageUrl: vehicle?.imageUrl,
          carImage: state.carImage,
        ),
        const SizedBox(height: AppConstants.space16),
        EmptyStateCard(
          title: 'garage.car_added_card_title'.tr(),
          subtitle: 'garage.car_added_card_body'.tr(),
        ),
        const SizedBox(height: AppConstants.space16),
        MainButton(
          label: 'garage.open_dashboard'.tr(),
          onPressed: () {
            if (vehicle != null) {
              pushReplacement(
                context,
                Routes.vehicleDashboardPath(vehicle.id),
              );
            } else {
              pop(context, true);
            }
          },
        ),
        const SizedBox(height: AppConstants.space12),
        MainButton(
          label: 'garage.back_to_garage'.tr(),
          variant: MainButtonVariant.secondary,
          onPressed: () => pop(context, true),
        ),
      ],
    );
  }
}

class _CatalogOptionCard extends StatelessWidget {
  const _CatalogOptionCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isSelected = false,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: AppConstants.borderRadius20,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppConstants.borderRadius20,
        child: Container(
          padding: AppConstants.paddingCard,
          decoration: BoxDecoration(
            borderRadius: AppConstants.borderRadius20,
            border: Border.all(
              color: isSelected ? scheme.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textTheme.titleLarge?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppConstants.space4),
                    Text(
                      subtitle,
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.chevron_right_rounded,
                color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
