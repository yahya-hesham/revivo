import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/apis/api_error.dart';
import '../../data/models/maintenance_models.dart';
import '../../data/repository/maintenance_repo.dart';
import 'record_maintenance_state.dart';

/// Handles the 2-step maintenance save order (`record` → `schedule`),
/// preserving the saved record on partial failure so `retrySchedule()` never
/// duplicates the maintenance record (Figma `Partial save` `4:240`).
class RecordMaintenanceCubit extends Cubit<RecordMaintenanceState> {
  RecordMaintenanceCubit({
    Future<MaintenanceRecordModel> Function({
      required int vehicleId,
      required MaintenanceRequestModel request,
    })? createMaintenance,
    Future<MaintenanceRecordModel> Function({
      required int vehicleId,
      required int recordId,
      required MaintenanceRequestModel request,
    })? updateMaintenance,
    Future<void> Function({required int vehicleId, required int recordId})?
        deleteMaintenance,
    Future<MaintenanceStatusModel> Function({
      required int vehicleId,
      required int itemId,
      required ScheduleRequestModel request,
    })? upsertSchedule,
  })  : _createMaintenance =
            createMaintenance ?? MaintenanceRepo.createMaintenance,
        _updateMaintenance =
            updateMaintenance ?? MaintenanceRepo.updateMaintenance,
        _deleteMaintenance =
            deleteMaintenance ?? MaintenanceRepo.deleteMaintenance,
        _upsertSchedule = upsertSchedule ?? MaintenanceRepo.upsertSchedule,
        super(const RecordMaintenanceState());

  final Future<MaintenanceRecordModel> Function({
    required int vehicleId,
    required MaintenanceRequestModel request,
  }) _createMaintenance;
  final Future<MaintenanceRecordModel> Function({
    required int vehicleId,
    required int recordId,
    required MaintenanceRequestModel request,
  }) _updateMaintenance;
  final Future<void> Function({required int vehicleId, required int recordId})
      _deleteMaintenance;
  final Future<MaintenanceStatusModel> Function({
    required int vehicleId,
    required int itemId,
    required ScheduleRequestModel request,
  }) _upsertSchedule;

  Future<void> createRecord({
    required int vehicleId,
    required MaintenanceRequestModel request,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final created = await _createMaintenance(
        vehicleId: vehicleId,
        request: request,
      );
      if (!isClosed) {
        emit(
          state.copyWith(
            step: 1,
            savedRecord: created,
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
            errorMessage: 'Failed to save maintenance record.',
          ),
        );
      }
    }
  }

  Future<void> saveSchedule({
    required int vehicleId,
    required ScheduleRequestModel request,
  }) async {
    final record = state.savedRecord;
    if (record == null) return;

    emit(
      state.copyWith(
        isSubmitting: true,
        pendingSchedule: request,
        clearError: true,
      ),
    );

    try {
      final status = await _upsertSchedule(
        vehicleId: vehicleId,
        itemId: record.itemId,
        request: request,
      );
      if (!isClosed) {
        emit(
          state.copyWith(
            step: 3,
            savedSchedule: status,
            isSubmitting: false,
          ),
        );
      }
    } on ApiException catch (e) {
      if (!isClosed) {
        // Record is already saved — transition to Partial Save (`4:240`)
        // so the user can retry ONLY the schedule step without duplicating.
        emit(
          state.copyWith(
            step: 2,
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
            step: 2,
            isSubmitting: false,
            errorMessage: 'Could not save the next-service schedule.',
          ),
        );
      }
    }
  }

  Future<void> retrySchedule(int vehicleId) async {
    final pending = state.pendingSchedule;
    if (pending == null) return;
    await saveSchedule(vehicleId: vehicleId, request: pending);
  }

  void skipSchedule() {
    emit(state.copyWith(step: 3, clearError: true));
  }

  Future<void> updateRecord({
    required int vehicleId,
    required int recordId,
    required MaintenanceRequestModel request,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final updated = await _updateMaintenance(
        vehicleId: vehicleId,
        recordId: recordId,
        request: request,
      );
      if (!isClosed) {
        emit(
          state.copyWith(
            step: 3,
            savedRecord: updated,
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
            errorMessage: 'Failed to update maintenance record.',
          ),
        );
      }
    }
  }

  Future<void> deleteRecord({
    required int vehicleId,
    required int recordId,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      await _deleteMaintenance(vehicleId: vehicleId, recordId: recordId);
      if (!isClosed) {
        emit(state.copyWith(isSubmitting: false, isDeleted: true));
      }
    } on ApiException catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: e.message,
            isConflict: e.isConflict,
          ),
        );
      }
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: 'Failed to delete maintenance record.',
          ),
        );
      }
    }
  }
}
