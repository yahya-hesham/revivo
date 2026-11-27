import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/apis/api_error.dart';
import '../../data/models/vehicle_model.dart';
import '../../data/repository/garage_repo.dart';
import 'garage_state.dart';

class GarageCubit extends Cubit<GarageState> {
  GarageCubit({
    Future<List<VehicleModel>> Function()? fetchOwned,
    Future<List<VehicleModel>> Function()? fetchShared,
  })  : _fetchOwned = fetchOwned ?? GarageRepo.fetchOwnedVehicles,
        _fetchShared = fetchShared ?? GarageRepo.fetchSharedVehicles,
        super(const GarageInitial());

  final Future<List<VehicleModel>> Function() _fetchOwned;
  final Future<List<VehicleModel>> Function() _fetchShared;

  Future<void> loadGarage() async {
    emit(const GarageLoading());
    try {
      final results = await Future.wait<List<VehicleModel>>([
        _fetchOwned(),
        _fetchShared(),
      ]);
      if (!isClosed) {
        emit(
          GarageLoaded(
            ownedVehicles: List.unmodifiable(results[0]),
            sharedVehicles: List.unmodifiable(results[1]),
          ),
        );
      }
    } on ApiException catch (e) {
      if (!isClosed) emit(GarageError(e.message));
    } catch (_) {
      if (!isClosed) {
        emit(const GarageError('Something went wrong. Please try again.'));
      }
    }
  }
}
