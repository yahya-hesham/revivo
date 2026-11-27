import '../../data/models/vehicle_model.dart';

abstract class GarageState {
  const GarageState();
}

class GarageInitial extends GarageState {
  const GarageInitial();
}

class GarageLoading extends GarageState {
  const GarageLoading();
}

class GarageLoaded extends GarageState {
  const GarageLoaded({
    required this.ownedVehicles,
    required this.sharedVehicles,
  });

  final List<VehicleModel> ownedVehicles;
  final List<VehicleModel> sharedVehicles;

  bool get isEmpty => ownedVehicles.isEmpty && sharedVehicles.isEmpty;
  int get totalCount => ownedVehicles.length + sharedVehicles.length;
}

class GarageError extends GarageState {
  const GarageError(this.message);

  final String message;
}
