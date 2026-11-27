import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/apis/api_error.dart';
import '../../data/models/vehicle_model.dart';
import '../../data/repository/garage_repo.dart';
import 'vehicle_dashboard_state.dart';

class VehicleDashboardCubit extends Cubit<VehicleDashboardState> {
  VehicleDashboardCubit({
    Future<VehicleDashboardData> Function(int vehicleId)? fetchDashboard,
    Future<VehicleModel> Function({
      required int vehicleId,
      required VehicleRequestModel request,
    })? updateVehicle,
    Future<void> Function(int vehicleId)? deleteVehicle,
  })  : _fetchDashboard = fetchDashboard ?? GarageRepo.fetchVehicleDashboard,
        _updateVehicle = updateVehicle ?? GarageRepo.updateVehicle,
        _deleteVehicle = deleteVehicle ?? GarageRepo.deleteVehicle,
        super(const VehicleDashboardInitial());

  final Future<VehicleDashboardData> Function(int vehicleId) _fetchDashboard;
  final Future<VehicleModel> Function({
    required int vehicleId,
    required VehicleRequestModel request,
  }) _updateVehicle;
  final Future<void> Function(int vehicleId) _deleteVehicle;

  VehicleDashboardData? _latestData;

  Future<void> loadDashboard(int vehicleId) async {
    emit(const VehicleDashboardLoading());
    try {
      final data = await _fetchDashboard(vehicleId);
      _latestData = data;
      if (!isClosed) emit(VehicleDashboardLoaded(data));
    } on ApiException catch (e) {
      if (!isClosed) {
        emit(
          VehicleDashboardError(
            message: e.message,
            isNotFound: e.isNotFound,
          ),
        );
      }
    } catch (_) {
      if (!isClosed) {
        emit(
          const VehicleDashboardError(
            message: 'Something went wrong. Please try again.',
          ),
        );
      }
    }
  }

  Future<void> updateVehicle({
    required VehicleModel existing,
    required int year,
    String? nickname,
  }) async {
    emit(VehicleActionLoading(_latestData));
    try {
      final request = VehicleRequestModel(
        carModelId: existing.carModelId,
        year: year,
        currentMileageKm: existing.currentMileageKm,
        nickname: nickname,
        imageUrl: existing.imageUrl,
      );
      final updated = await _updateVehicle(
        vehicleId: existing.id,
        request: request,
      );
      if (!isClosed) emit(VehicleUpdatedSuccess(updated));
    } on ApiException catch (e) {
      if (!isClosed) {
        emit(
          VehicleDashboardError(
            message: e.message,
            isNotFound: e.isNotFound,
            isConflict: e.isConflict,
            fieldErrors: e.fieldErrors,
            previousData: _latestData,
          ),
        );
      }
    } catch (_) {
      if (!isClosed) {
        emit(
          VehicleDashboardError(
            message: 'Failed to update vehicle.',
            previousData: _latestData,
          ),
        );
      }
    }
  }

  Future<void> deleteVehicle(int vehicleId) async {
    emit(VehicleActionLoading(_latestData));
    try {
      await _deleteVehicle(vehicleId);
      if (!isClosed) emit(const VehicleDeletedSuccess());
    } on ApiException catch (e) {
      if (!isClosed) {
        emit(
          VehicleDashboardError(
            message: e.message,
            isNotFound: e.isNotFound,
            isConflict: e.isConflict,
            previousData: _latestData,
          ),
        );
      }
    } catch (_) {
      if (!isClosed) {
        emit(
          VehicleDashboardError(
            message: 'Failed to delete vehicle.',
            previousData: _latestData,
          ),
        );
      }
    }
  }
}
