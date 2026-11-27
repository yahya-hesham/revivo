import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revivo/core/services/apis/api_error.dart';
import 'package:revivo/features/garage/data/models/car_catalog_models.dart';
import 'package:revivo/features/garage/data/models/vehicle_model.dart';
import 'package:revivo/features/garage/presentation/cubit/add_vehicle_cubit.dart';
import 'package:revivo/features/garage/presentation/cubit/add_vehicle_state.dart';
import 'package:revivo/features/garage/presentation/cubit/garage_cubit.dart';
import 'package:revivo/features/garage/presentation/cubit/garage_state.dart';
import 'package:revivo/features/garage/presentation/cubit/vehicle_dashboard_cubit.dart';
import 'package:revivo/features/garage/presentation/cubit/vehicle_dashboard_state.dart';

void main() {
  final sampleVehicle = VehicleModel(
    id: 7,
    ownerId: '11111111-1111-1111-1111-111111111111',
    carModelId: 2,
    year: 2022,
    currentMileageKm: 48200,
    nickname: 'My daily',
    createdAt: DateTime.utc(2026, 11, 1),
    makeName: 'Toyota',
    modelName: 'Corolla',
  );

  group('Garage models', () {
    test('CarImageModel handles found vs noImage statuses', () {
      final found = CarImageModel.fromJson({
        'status': 'found',
        'imageUrl': 'https://images.unsplash.com/photo-1',
        'photographerName': 'Jane',
        'isExactVehicle': false,
        'message': 'Illustrative photo',
      });
      expect(found.isFound, isTrue);

      final missing = CarImageModel.fromJson({
        'status': 'noImage',
        'imageUrl': null,
        'isExactVehicle': false,
        'message': 'No suitable photo was found.',
      });
      expect(missing.isFound, isFalse);
    });

    test('VehicleRequestModel trims optional nickname to null when blank', () {
      const req = VehicleRequestModel(
        carModelId: 2,
        year: 2022,
        currentMileageKm: 48200,
        nickname: '   ',
      );
      expect(req.toJson()['nickname'], isNull);
    });
  });

  group('GarageCubit', () {
    blocTest<GarageCubit, GarageState>(
      'loads owned and shared vehicles in parallel',
      build: () => GarageCubit(
        fetchOwned: () async => [sampleVehicle],
        fetchShared: () async => [sampleVehicle.copyWith(isShared: true)],
      ),
      act: (cubit) => cubit.loadGarage(),
      expect: () => [
        isA<GarageLoading>(),
        isA<GarageLoaded>()
            .having((s) => s.ownedVehicles.length, 'owned', 1)
            .having((s) => s.sharedVehicles.length, 'shared', 1)
            .having((s) => s.totalCount, 'total', 2),
      ],
    );
  });

  group('AddVehicleCubit', () {
    const make = CarMakeModel(id: 1, name: 'Toyota');
    const model = CarModelItem(id: 2, carMakeId: 1, name: 'Corolla');

    blocTest<AddVehicleCubit, AddVehicleState>(
      'walks through make → model/year → details → created',
      build: () => AddVehicleCubit(
        fetchMakes: ({search}) async => [make],
        fetchModels: ({required makeId, search}) async => [model],
        fetchModelYears: (modelId) async => [2024, 2022],
        fetchCarImage: ({required modelId, required year}) async =>
            const CarImageModel(
          status: 'noImage',
          isExactVehicle: false,
          message: 'No photo',
        ),
        createVehicle: (_) async => sampleVehicle,
      ),
      act: (cubit) async {
        await cubit.loadMakes();
        await cubit.selectMake(make);
        await cubit.selectModel(model);
        cubit.selectYear(2022);
        await cubit.continueToDetails();
        await cubit.submitVehicle(currentMileageKm: 48200, nickname: 'My daily');
      },
      verify: (cubit) {
        expect(cubit.state.step, 3);
        expect(cubit.state.createdVehicle?.id, 7);
        expect(cubit.state.carImage?.isFound, isFalse);
      },
    );
  });

  group('VehicleDashboardCubit', () {
    blocTest<VehicleDashboardCubit, VehicleDashboardState>(
      'surfaces 409 conflict message on delete when maintenance records exist',
      build: () => VehicleDashboardCubit(
        deleteVehicle: (_) async => throw const ApiException(
          statusCode: 409,
          message: 'Delete maintenance records before deleting this vehicle.',
        ),
      ),
      act: (cubit) => cubit.deleteVehicle(7),
      expect: () => [
        isA<VehicleActionLoading>(),
        isA<VehicleDashboardError>()
            .having((s) => s.isConflict, 'isConflict', true)
            .having(
              (s) => s.message,
              'message',
              'Delete maintenance records before deleting this vehicle.',
            ),
      ],
    );
  });
}
