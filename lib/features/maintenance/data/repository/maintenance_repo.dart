import 'package:dio/dio.dart';
import '../../../../core/services/apis/api_error.dart';
import '../../../../core/services/apis/apis.dart';
import '../../../../core/services/apis/dio_provider.dart';
import '../models/maintenance_models.dart';

/// Repository for maintenance records and periodic service schedules.
abstract final class MaintenanceRepo {
  static Future<MaintenancePageModel> fetchMaintenancePage({
    required int vehicleId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await DioProvider.get(
        endpoint: Apis.maintenance(vehicleId),
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return MaintenancePageModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw const ApiException(message: 'Failed to load maintenance history.');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  static Future<MaintenanceRecordModel> fetchMaintenanceById({
    required int vehicleId,
    required int recordId,
  }) async {
    try {
      final response = await DioProvider.get(
        endpoint: Apis.maintenanceById(vehicleId, recordId),
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return MaintenanceRecordModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw const ApiException(message: 'Failed to load maintenance record.');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  static Future<MaintenanceRecordModel> createMaintenance({
    required int vehicleId,
    required MaintenanceRequestModel request,
  }) async {
    try {
      final response = await DioProvider.post(
        endpoint: Apis.maintenance(vehicleId),
        data: request.toJson(),
      );
      if ((response.statusCode == 201 || response.statusCode == 200) &&
          response.data is Map<String, dynamic>) {
        return MaintenanceRecordModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw const ApiException(message: 'Failed to save maintenance record.');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  static Future<MaintenanceRecordModel> updateMaintenance({
    required int vehicleId,
    required int recordId,
    required MaintenanceRequestModel request,
  }) async {
    try {
      final response = await DioProvider.put(
        endpoint: Apis.maintenanceById(vehicleId, recordId),
        data: request.toJson(),
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return MaintenanceRecordModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw const ApiException(message: 'Failed to update maintenance record.');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  static Future<void> deleteMaintenance({
    required int vehicleId,
    required int recordId,
  }) async {
    try {
      await DioProvider.delete(
        endpoint: Apis.maintenanceById(vehicleId, recordId),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  static Future<MaintenanceStatusModel> upsertSchedule({
    required int vehicleId,
    required int itemId,
    required ScheduleRequestModel request,
  }) async {
    try {
      final response = await DioProvider.put(
        endpoint: Apis.maintenanceSchedule(vehicleId, itemId),
        data: request.toJson(),
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return MaintenanceStatusModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw const ApiException(message: 'Failed to save service schedule.');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  static Future<List<MaintenanceStatusModel>> fetchMaintenanceStatus(
    int vehicleId,
  ) async {
    try {
      final response = await DioProvider.get(
        endpoint: Apis.maintenanceStatus(vehicleId),
      );
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map(
              (e) => MaintenanceStatusModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      }
      throw const ApiException(message: 'Failed to load maintenance status.');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  static Future<List<MaintenanceStatusModel>> fetchUpcomingMaintenance(
    int vehicleId,
  ) async {
    try {
      final response = await DioProvider.get(
        endpoint: Apis.upcomingMaintenance(vehicleId),
      );
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map(
              (e) => MaintenanceStatusModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      }
      throw const ApiException(message: 'Failed to load upcoming maintenance.');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
