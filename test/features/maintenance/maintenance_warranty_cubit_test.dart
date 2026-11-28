import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revivo/core/services/apis/api_error.dart';
import 'package:revivo/features/maintenance/data/models/maintenance_models.dart';
import 'package:revivo/features/maintenance/presentation/cubit/record_maintenance_cubit.dart';
import 'package:revivo/features/maintenance/presentation/cubit/record_maintenance_state.dart';
import 'package:revivo/features/warranties/data/models/warranty_models.dart';
import 'package:revivo/features/warranties/presentation/cubit/warranty_cubit.dart';
import 'package:revivo/features/warranties/presentation/cubit/warranty_state.dart';

void main() {
  final sampleRecord = MaintenanceRecordModel(
    id: 3,
    vehicleId: 7,
    itemId: 4,
    category: 'Fluids',
    itemName: 'Engine oil change',
    maintenanceDate: '2026-11-16',
    mileageKm: 48200,
    costEgp: 1450.0,
    createdAt: DateTime.utc(2026, 11, 16),
  );

  const sampleStatus = MaintenanceStatusModel(
    itemId: 4,
    category: 'Fluids',
    itemName: 'Engine oil change',
    intervalKm: 10000,
    warningKm: 1000,
    warningDays: 30,
    nextDueMileageKm: 58200,
    remainingKm: 10000,
    status: 'OnTrack',
  );

  final sampleWarranty = WarrantyModel(
    maintenanceRecordId: 3,
    vehicleId: 7,
    itemId: 4,
    itemName: 'Battery',
    durationMonths: 12,
    startDate: '2026-11-01',
    expirationDate: '2027-11-01',
    warningDays: 30,
    remainingDays: 348,
    status: 'Active',
    createdAt: DateTime.utc(2026, 11, 1),
  );

  group('RecordMaintenanceCubit partial-save recovery', () {
    test('retries only the failed schedule step without duplicating the record',
        () async {
      var createCalls = 0;
      var scheduleCalls = 0;

      final cubit = RecordMaintenanceCubit(
        createMaintenance: ({required vehicleId, required request}) async {
          createCalls++;
          return sampleRecord;
        },
        upsertSchedule: ({
          required vehicleId,
          required itemId,
          required request,
        }) async {
          scheduleCalls++;
          if (scheduleCalls == 1) {
            throw const ApiException(
              message: 'Network error',
              isNetworkError: true,
            );
          }
          return sampleStatus;
        },
      );

      await cubit.createRecord(
        vehicleId: 7,
        request: const MaintenanceRequestModel(
          category: 'Fluids',
          itemName: 'Engine oil change',
          maintenanceDate: '2026-11-16',
          mileageKm: 48200,
          costEgp: 1450.0,
        ),
      );
      expect(cubit.state.step, 1);
      expect(createCalls, 1);

      // First schedule attempt fails → lands on Partial Save step (2)
      await cubit.saveSchedule(
        vehicleId: 7,
        request: const ScheduleRequestModel(intervalKm: 10000),
      );
      expect(cubit.state.step, 2);
      expect(cubit.state.savedRecord?.id, 3);
      expect(scheduleCalls, 1);

      // Retry schedule → succeeds without calling createMaintenance again
      await cubit.retrySchedule(7);
      expect(cubit.state.step, 3);
      expect(createCalls, 1);
      expect(scheduleCalls, 2);

      await cubit.close();
    });

    blocTest<RecordMaintenanceCubit, RecordMaintenanceState>(
      'surfaces 409 conflict when deleting a record with an attached warranty',
      build: () => RecordMaintenanceCubit(
        deleteMaintenance: ({required vehicleId, required recordId}) async =>
            throw const ApiException(
          statusCode: 409,
          message: 'Delete the warranty before deleting this maintenance record.',
        ),
      ),
      act: (cubit) => cubit.deleteRecord(vehicleId: 7, recordId: 3),
      verify: (cubit) {
        expect(cubit.state.isConflict, isTrue);
        expect(
          cubit.state.errorMessage,
          'Delete the warranty before deleting this maintenance record.',
        );
      },
    );
  });

  group('WarrantyCubit', () {
    blocTest<WarrantyCubit, WarrantyState>(
      'loads vehicle warranties sorted by expiration',
      build: () => WarrantyCubit(
        fetchWarranties: (_) async => [sampleWarranty],
      ),
      act: (cubit) => cubit.loadWarranties(7),
      expect: () => [
        isA<WarrantyLoading>(),
        isA<WarrantiesListLoaded>()
            .having((s) => s.warranties.length, 'count', 1),
      ],
    );

    blocTest<WarrantyCubit, WarrantyState>(
      'saves warranty and emits WarrantySavedSuccess',
      build: () => WarrantyCubit(
        upsertWarranty: ({
          required vehicleId,
          required recordId,
          required request,
        }) async =>
            sampleWarranty,
      ),
      act: (cubit) => cubit.saveWarranty(
        vehicleId: 7,
        recordId: 3,
        request: const WarrantyRequestModel(durationMonths: 12),
      ),
      expect: () => [
        isA<WarrantyActionLoading>(),
        isA<WarrantySavedSuccess>()
            .having((s) => s.warranty.maintenanceRecordId, 'recordId', 3),
      ],
    );
  });
}
