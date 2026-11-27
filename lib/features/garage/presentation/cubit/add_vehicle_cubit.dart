import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/apis/api_error.dart';
import '../../data/models/car_catalog_models.dart';
import '../../data/models/vehicle_model.dart';
import '../../data/repository/garage_repo.dart';
import 'add_vehicle_state.dart';

class AddVehicleCubit extends Cubit<AddVehicleState> {
  AddVehicleCubit({
    Future<List<CarMakeModel>> Function({String? search})? fetchMakes,
    Future<List<CarModelItem>> Function({required int makeId, String? search})?
        fetchModels,
    Future<List<int>> Function(int modelId)? fetchModelYears,
    Future<CarImageModel> Function({required int modelId, required int year})?
        fetchCarImage,
    Future<VehicleModel> Function(VehicleRequestModel request)? createVehicle,
  })  : _fetchMakes = fetchMakes ?? GarageRepo.fetchMakes,
        _fetchModels = fetchModels ?? GarageRepo.fetchModels,
        _fetchModelYears = fetchModelYears ?? GarageRepo.fetchModelYears,
        _fetchCarImage = fetchCarImage ?? GarageRepo.fetchCarImage,
        _createVehicle = createVehicle ?? GarageRepo.createVehicle,
        super(const AddVehicleState());

  final Future<List<CarMakeModel>> Function({String? search}) _fetchMakes;
  final Future<List<CarModelItem>> Function({
    required int makeId,
    String? search,
  }) _fetchModels;
  final Future<List<int>> Function(int modelId) _fetchModelYears;
  final Future<CarImageModel> Function({required int modelId, required int year})
      _fetchCarImage;
  final Future<VehicleModel> Function(VehicleRequestModel request)
      _createVehicle;

  Future<void> loadMakes({String? search}) async {
    emit(state.copyWith(isLoadingMakes: true, clearError: true));
    try {
      final makes = await _fetchMakes(search: search);
      if (!isClosed) {
        emit(
          state.copyWith(
            makes: List.unmodifiable(makes),
            isLoadingMakes: false,
          ),
        );
      }
    } on ApiException catch (e) {
      if (!isClosed) {
        emit(state.copyWith(isLoadingMakes: false, errorMessage: e.message));
      }
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isLoadingMakes: false,
            errorMessage: 'Failed to load car makes.',
          ),
        );
      }
    }
  }

  Future<void> selectMake(CarMakeModel make) async {
    emit(
      state.copyWith(
        step: 1,
        selectedMake: make,
        models: const [],
        years: const [],
        clearSelectedModel: true,
        clearSelectedYear: true,
        clearCarImage: true,
        isLoadingModels: true,
        clearError: true,
      ),
    );
    await searchModels();
  }

  Future<void> searchModels({String? search}) async {
    final make = state.selectedMake;
    if (make == null) return;
    emit(state.copyWith(isLoadingModels: true, clearError: true));
    try {
      final models = await _fetchModels(makeId: make.id, search: search);
      if (!isClosed) {
        emit(
          state.copyWith(
            models: List.unmodifiable(models),
            isLoadingModels: false,
          ),
        );
      }
    } on ApiException catch (e) {
      if (!isClosed) {
        emit(state.copyWith(isLoadingModels: false, errorMessage: e.message));
      }
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isLoadingModels: false,
            errorMessage: 'Failed to load models.',
          ),
        );
      }
    }
  }

  Future<void> selectModel(CarModelItem model) async {
    emit(
      state.copyWith(
        selectedModel: model,
        years: const [],
        clearSelectedYear: true,
        clearCarImage: true,
        isLoadingYears: true,
        clearError: true,
      ),
    );
    try {
      final years = await _fetchModelYears(model.id);
      if (!isClosed) {
        emit(
          state.copyWith(
            years: List.unmodifiable(years),
            selectedYear: years.isNotEmpty ? years.first : null,
            isLoadingYears: false,
          ),
        );
      }
    } on ApiException catch (e) {
      if (!isClosed) {
        emit(state.copyWith(isLoadingYears: false, errorMessage: e.message));
      }
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isLoadingYears: false,
            errorMessage: 'Failed to load production years.',
          ),
        );
      }
    }
  }

  void selectYear(int year) {
    emit(state.copyWith(selectedYear: year, clearError: true));
  }

  Future<void> continueToDetails() async {
    final model = state.selectedModel;
    final year = state.selectedYear;
    if (model == null || year == null) return;

    emit(
      state.copyWith(
        step: 2,
        isLoadingImage: true,
        clearCarImage: true,
        clearError: true,
      ),
    );
    try {
      final image = await _fetchCarImage(modelId: model.id, year: year);
      if (!isClosed) {
        emit(state.copyWith(carImage: image, isLoadingImage: false));
      }
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            carImage: const CarImageModel(
              status: 'unavailable',
              isExactVehicle: false,
              message: 'Photo unavailable.',
            ),
            isLoadingImage: false,
          ),
        );
      }
    }
  }

  void goBackStep() {
    if (state.step > 0 && state.step < 3) {
      emit(state.copyWith(step: state.step - 1, clearError: true));
    }
  }

  Future<void> submitVehicle({
    required int currentMileageKm,
    String? nickname,
  }) async {
    final make = state.selectedMake;
    final model = state.selectedModel;
    final year = state.selectedYear;
    if (model == null || year == null) return;

    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      if (make != null) {
        GarageRepo.rememberCatalogName(
          modelId: model.id,
          makeName: make.name,
          modelName: model.name,
        );
      }
      final request = VehicleRequestModel(
        carModelId: model.id,
        year: year,
        currentMileageKm: currentMileageKm,
        nickname: nickname,
        imageUrl: state.carImage?.isFound == true ? state.carImage!.imageUrl : null,
      );
      final created = await _createVehicle(request);
      if (!isClosed) {
        emit(
          state.copyWith(
            step: 3,
            createdVehicle: created.copyWith(
              makeName: make?.name,
              modelName: model.name,
            ),
            isSubmitting: false,
          ),
        );
      }
    } on ApiException catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: e.message,
            fieldErrors: e.fieldErrors,
          ),
        );
      }
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: 'Failed to add vehicle.',
          ),
        );
      }
    }
  }
}
