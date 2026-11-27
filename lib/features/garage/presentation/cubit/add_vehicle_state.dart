import '../../data/models/car_catalog_models.dart';
import '../../data/models/vehicle_model.dart';

/// Immutable state for the 3-step Add Vehicle wizard + Car Added confirmation.
class AddVehicleState {
  const AddVehicleState({
    this.step = 0,
    this.makes = const [],
    this.models = const [],
    this.years = const [],
    this.selectedMake,
    this.selectedModel,
    this.selectedYear,
    this.carImage,
    this.createdVehicle,
    this.isLoadingMakes = false,
    this.isLoadingModels = false,
    this.isLoadingYears = false,
    this.isLoadingImage = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  /// 0 = Make, 1 = Model & Year, 2 = Car details, 3 = Car added.
  final int step;
  final List<CarMakeModel> makes;
  final List<CarModelItem> models;
  final List<int> years;
  final CarMakeModel? selectedMake;
  final CarModelItem? selectedModel;
  final int? selectedYear;
  final CarImageModel? carImage;
  final VehicleModel? createdVehicle;

  final bool isLoadingMakes;
  final bool isLoadingModels;
  final bool isLoadingYears;
  final bool isLoadingImage;
  final bool isSubmitting;

  final String? errorMessage;
  final Map<String, List<String>> fieldErrors;

  String? fieldError(String fieldName) {
    final errors = fieldErrors[fieldName.toLowerCase()];
    if (errors == null || errors.isEmpty) return null;
    return errors.first;
  }

  AddVehicleState copyWith({
    int? step,
    List<CarMakeModel>? makes,
    List<CarModelItem>? models,
    List<int>? years,
    CarMakeModel? selectedMake,
    CarModelItem? selectedModel,
    bool clearSelectedModel = false,
    int? selectedYear,
    bool clearSelectedYear = false,
    CarImageModel? carImage,
    bool clearCarImage = false,
    VehicleModel? createdVehicle,
    bool? isLoadingMakes,
    bool? isLoadingModels,
    bool? isLoadingYears,
    bool? isLoadingImage,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    Map<String, List<String>>? fieldErrors,
  }) {
    return AddVehicleState(
      step: step ?? this.step,
      makes: makes ?? this.makes,
      models: models ?? this.models,
      years: years ?? this.years,
      selectedMake: selectedMake ?? this.selectedMake,
      selectedModel:
          clearSelectedModel ? null : (selectedModel ?? this.selectedModel),
      selectedYear:
          clearSelectedYear ? null : (selectedYear ?? this.selectedYear),
      carImage: clearCarImage ? null : (carImage ?? this.carImage),
      createdVehicle: createdVehicle ?? this.createdVehicle,
      isLoadingMakes: isLoadingMakes ?? this.isLoadingMakes,
      isLoadingModels: isLoadingModels ?? this.isLoadingModels,
      isLoadingYears: isLoadingYears ?? this.isLoadingYears,
      isLoadingImage: isLoadingImage ?? this.isLoadingImage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      fieldErrors: clearError ? const {} : (fieldErrors ?? this.fieldErrors),
    );
  }
}
