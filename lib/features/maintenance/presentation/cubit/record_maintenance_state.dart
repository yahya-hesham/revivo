import '../../data/models/maintenance_models.dart';

/// Immutable state for Record / Next Service / Partial Save / Edit / Delete.
class RecordMaintenanceState {
  const RecordMaintenanceState({
    this.step = 0,
    this.savedRecord,
    this.savedSchedule,
    this.pendingSchedule,
    this.isSubmitting = false,
    this.isDeleted = false,
    this.errorMessage,
    this.isConflict = false,
    this.fieldErrors = const {},
  });

  /// 0 = Record form, 1 = Next service schedule, 2 = Partial save retry, 3 = Complete.
  final int step;
  final MaintenanceRecordModel? savedRecord;
  final MaintenanceStatusModel? savedSchedule;
  final ScheduleRequestModel? pendingSchedule;
  final bool isSubmitting;
  final bool isDeleted;
  final String? errorMessage;
  final bool isConflict;
  final Map<String, List<String>> fieldErrors;

  String? fieldError(String fieldName) {
    final errors = fieldErrors[fieldName.toLowerCase()];
    if (errors == null || errors.isEmpty) return null;
    return errors.first;
  }

  RecordMaintenanceState copyWith({
    int? step,
    MaintenanceRecordModel? savedRecord,
    MaintenanceStatusModel? savedSchedule,
    ScheduleRequestModel? pendingSchedule,
    bool? isSubmitting,
    bool? isDeleted,
    String? errorMessage,
    bool clearError = false,
    bool? isConflict,
    Map<String, List<String>>? fieldErrors,
  }) {
    return RecordMaintenanceState(
      step: step ?? this.step,
      savedRecord: savedRecord ?? this.savedRecord,
      savedSchedule: savedSchedule ?? this.savedSchedule,
      pendingSchedule: pendingSchedule ?? this.pendingSchedule,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isDeleted: isDeleted ?? this.isDeleted,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isConflict: clearError ? false : (isConflict ?? this.isConflict),
      fieldErrors: clearError ? const {} : (fieldErrors ?? this.fieldErrors),
    );
  }
}
