import '../../data/models/vehicle_model.dart';

abstract class VehicleDashboardState {
  const VehicleDashboardState();
}

class VehicleDashboardInitial extends VehicleDashboardState {
  const VehicleDashboardInitial();
}

class VehicleDashboardLoading extends VehicleDashboardState {
  const VehicleDashboardLoading();
}

class VehicleDashboardLoaded extends VehicleDashboardState {
  const VehicleDashboardLoaded(this.data);

  final VehicleDashboardData data;
}

class VehicleActionLoading extends VehicleDashboardState {
  const VehicleActionLoading(this.currentData);

  final VehicleDashboardData? currentData;
}

class VehicleUpdatedSuccess extends VehicleDashboardState {
  const VehicleUpdatedSuccess(this.vehicle);

  final VehicleModel vehicle;
}

class VehicleDeletedSuccess extends VehicleDashboardState {
  const VehicleDeletedSuccess();
}

class VehicleDashboardError extends VehicleDashboardState {
  const VehicleDashboardError({
    required this.message,
    this.isNotFound = false,
    this.isConflict = false,
    this.fieldErrors = const {},
    this.previousData,
  });

  final String message;
  final bool isNotFound;
  final bool isConflict;
  final Map<String, List<String>> fieldErrors;
  final VehicleDashboardData? previousData;

  String? fieldError(String fieldName) {
    final errors = fieldErrors[fieldName.toLowerCase()];
    if (errors == null || errors.isEmpty) return null;
    return errors.first;
  }
}
