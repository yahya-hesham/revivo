import 'package:dio/dio.dart';
import '../../../../core/services/apis/api_error.dart';
import '../../../../core/services/apis/apis.dart';
import '../../../../core/services/apis/dio_provider.dart';
import '../models/warranty_models.dart';

/// Repository for vehicle warranties.
abstract final class WarrantiesRepo {
  static Future<List<WarrantyModel>> fetchVehicleWarranties(
    int vehicleId,
  ) async {
    try {
      final response = await DioProvider.get(
        endpoint: Apis.warranties(vehicleId),
      );
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => WarrantyModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw const ApiException(message: 'Failed to load warranties.');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Returns `null` when no warranty exists for the record (HTTP 404).
  static Future<WarrantyModel?> fetchRecordWarranty({
    required int vehicleId,
    required int recordId,
  }) async {
    try {
      final response = await DioProvider.get(
        endpoint: Apis.recordWarranty(vehicleId, recordId),
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return WarrantyModel.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ApiException.fromDioException(e);
    }
  }

  static Future<WarrantyModel> upsertWarranty({
    required int vehicleId,
    required int recordId,
    required WarrantyRequestModel request,
  }) async {
    try {
      final response = await DioProvider.put(
        endpoint: Apis.recordWarranty(vehicleId, recordId),
        data: request.toJson(),
      );
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map<String, dynamic>) {
        return WarrantyModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ApiException(message: 'Failed to save warranty.');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  static Future<void> deleteWarranty({
    required int vehicleId,
    required int recordId,
  }) async {
    try {
      await DioProvider.delete(
        endpoint: Apis.recordWarranty(vehicleId, recordId),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
