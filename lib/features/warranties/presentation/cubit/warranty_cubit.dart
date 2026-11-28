import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/apis/api_error.dart';
import '../../data/models/warranty_models.dart';
import '../../data/repository/warranties_repo.dart';
import 'warranty_state.dart';

class WarrantyCubit extends Cubit<WarrantyState> {
  WarrantyCubit({
    Future<List<WarrantyModel>> Function(int vehicleId)? fetchWarranties,
    Future<WarrantyModel?> Function({
      required int vehicleId,
      required int recordId,
    })? fetchRecordWarranty,
    Future<WarrantyModel> Function({
      required int vehicleId,
      required int recordId,
      required WarrantyRequestModel request,
    })? upsertWarranty,
    Future<void> Function({required int vehicleId, required int recordId})?
        deleteWarranty,
  })  : _fetchWarranties =
            fetchWarranties ?? WarrantiesRepo.fetchVehicleWarranties,
        _fetchRecordWarranty =
            fetchRecordWarranty ?? WarrantiesRepo.fetchRecordWarranty,
        _upsertWarranty = upsertWarranty ?? WarrantiesRepo.upsertWarranty,
        _deleteWarranty = deleteWarranty ?? WarrantiesRepo.deleteWarranty,
        super(const WarrantyInitial());

  final Future<List<WarrantyModel>> Function(int vehicleId) _fetchWarranties;
  final Future<WarrantyModel?> Function({
    required int vehicleId,
    required int recordId,
  }) _fetchRecordWarranty;
  final Future<WarrantyModel> Function({
    required int vehicleId,
    required int recordId,
    required WarrantyRequestModel request,
  }) _upsertWarranty;
  final Future<void> Function({required int vehicleId, required int recordId})
      _deleteWarranty;

  Future<void> loadWarranties(int vehicleId) async {
    emit(const WarrantyLoading());
    try {
      final list = await _fetchWarranties(vehicleId);
      if (!isClosed) emit(WarrantiesListLoaded(List.unmodifiable(list)));
    } on ApiException catch (e) {
      if (!isClosed) emit(WarrantyError(message: e.message));
    } catch (_) {
      if (!isClosed) {
        emit(const WarrantyError(message: 'Failed to load warranties.'));
      }
    }
  }

  Future<void> loadRecordWarranty({
    required int vehicleId,
    required int recordId,
  }) async {
    emit(const WarrantyLoading());
    try {
      final warranty = await _fetchRecordWarranty(
        vehicleId: vehicleId,
        recordId: recordId,
      );
      if (!isClosed) emit(WarrantyDetailLoaded(warranty));
    } on ApiException catch (e) {
      if (!isClosed) emit(WarrantyError(message: e.message));
    } catch (_) {
      if (!isClosed) {
        emit(const WarrantyError(message: 'Failed to load warranty details.'));
      }
    }
  }

  Future<void> saveWarranty({
    required int vehicleId,
    required int recordId,
    required WarrantyRequestModel request,
  }) async {
    emit(const WarrantyActionLoading());
    try {
      final saved = await _upsertWarranty(
        vehicleId: vehicleId,
        recordId: recordId,
        request: request,
      );
      if (!isClosed) emit(WarrantySavedSuccess(saved));
    } on ApiException catch (e) {
      if (!isClosed) {
        emit(
          WarrantyError(
            message: e.message,
            fieldErrors: e.fieldErrors,
          ),
        );
      }
    } catch (_) {
      if (!isClosed) {
        emit(const WarrantyError(message: 'Failed to save warranty.'));
      }
    }
  }

  Future<void> deleteWarranty({
    required int vehicleId,
    required int recordId,
  }) async {
    emit(const WarrantyActionLoading());
    try {
      await _deleteWarranty(vehicleId: vehicleId, recordId: recordId);
      if (!isClosed) emit(const WarrantyDeletedSuccess());
    } on ApiException catch (e) {
      if (!isClosed) emit(WarrantyError(message: e.message));
    } catch (_) {
      if (!isClosed) {
        emit(const WarrantyError(message: 'Failed to delete warranty.'));
      }
    }
  }
}
