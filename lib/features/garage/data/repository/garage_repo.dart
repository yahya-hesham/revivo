import 'package:dio/dio.dart';
import '../../../../core/services/apis/api_error.dart';
import '../../../../core/services/apis/apis.dart';
import '../../../../core/services/apis/dio_provider.dart';
import '../../../../core/services/local/shared_pref.dart';
import '../models/car_catalog_models.dart';
import '../models/vehicle_model.dart';

/// Repository for Car Catalog, Garage vehicle CRUD, and Vehicle Dashboard summary.
abstract final class GarageRepo {
  /// In-memory cache mapping `carModelId` → `(makeName, modelName)` so vehicles
  /// display human-readable names without repeatedly re-fetching the catalog.
  static final Map<int, ({String makeName, String modelName})>
      _modelNameCache = {};

  static void rememberCatalogName({
    required int modelId,
    required String makeName,
    required String modelName,
  }) {
    _modelNameCache[modelId] = (makeName: makeName, modelName: modelName);
  }

  static VehicleModel _enrichFromCache(VehicleModel v) {
    final cached = _modelNameCache[v.carModelId];
    if (cached == null) return v;
    return v.copyWith(makeName: cached.makeName, modelName: cached.modelName);
  }

  // ---------------------------------------------------------------------------
  // Car catalog (public)
  // ---------------------------------------------------------------------------

  static Future<List<CarMakeModel>> fetchMakes({String? search}) async {
    try {
      final response = await DioProvider.get(
        endpoint: Apis.carMakes,
        queryParameters:
            (search != null && search.trim().isNotEmpty) ? {'search': search.trim()} : null,
      );
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => CarMakeModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw const ApiException(message: 'Failed to load car makes.');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  static Future<List<CarModelItem>> fetchModels({
    required int makeId,
    String? search,
  }) async {
    try {
      final params = <String, dynamic>{'makeId': makeId};
      if (search != null && search.trim().isNotEmpty) {
        params['search'] = search.trim();
      }
      final response = await DioProvider.get(
        endpoint: Apis.carModels,
        queryParameters: params,
      );
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => CarModelItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw const ApiException(message: 'Failed to load car models.');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  static Future<List<int>> fetchModelYears(int modelId) async {
    try {
      final response = await DioProvider.get(
        endpoint: Apis.carModelYears(modelId),
      );
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => (e as num).toInt())
            .toList();
      }
      throw const ApiException(message: 'Failed to load model years.');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  static Future<CarImageModel> fetchCarImage({
    required int modelId,
    required int year,
  }) async {
    try {
      final response = await DioProvider.get(
        endpoint: Apis.carImage,
        queryParameters: {'modelId': modelId, 'year': year},
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return CarImageModel.fromJson(response.data as Map<String, dynamic>);
      }
      return const CarImageModel(
        status: 'unavailable',
        isExactVehicle: false,
        message: 'Photo unavailable.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Vehicles CRUD
  // ---------------------------------------------------------------------------

  static Future<List<VehicleModel>> fetchOwnedVehicles() async {
    try {
      final response = await DioProvider.get(endpoint: Apis.vehicles);
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map(
              (e) => _enrichFromCache(
                VehicleModel.fromJson(e as Map<String, dynamic>),
              ),
            )
            .toList();
      }
      throw const ApiException(message: 'Failed to load vehicles.');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  static Future<List<VehicleModel>> fetchSharedVehicles() async {
    try {
      final response = await DioProvider.get(endpoint: Apis.sharedVehicles);
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map(
              (e) => _enrichFromCache(
                VehicleModel.fromJson(
                  e as Map<String, dynamic>,
                  isShared: true,
                ),
              ),
            )
            .toList();
      }
      throw const ApiException(message: 'Failed to load shared vehicles.');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  static Future<VehicleModel> fetchVehicleById(int vehicleId) async {
    try {
      final response = await DioProvider.get(
        endpoint: Apis.vehicleById(vehicleId),
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final currentUserId = SharedPref.getUserMap()?['id']?.toString();
        final vehicle = VehicleModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        final isShared =
            currentUserId != null && vehicle.ownerId != currentUserId;
        return _enrichFromCache(vehicle.copyWith(isShared: isShared));
      }
      throw const ApiException(message: 'Failed to load vehicle.');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  static Future<VehicleModel> createVehicle(VehicleRequestModel request) async {
    try {
      final response = await DioProvider.post(
        endpoint: Apis.vehicles,
        data: request.toJson(),
      );
      if ((response.statusCode == 201 || response.statusCode == 200) &&
          response.data is Map<String, dynamic>) {
        return _enrichFromCache(
          VehicleModel.fromJson(response.data as Map<String, dynamic>),
        );
      }
      throw const ApiException(message: 'Failed to add vehicle.');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  static Future<VehicleModel> updateVehicle({
    required int vehicleId,
    required VehicleRequestModel request,
  }) async {
    try {
      final response = await DioProvider.put(
        endpoint: Apis.vehicleById(vehicleId),
        data: request.toJson(),
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return _enrichFromCache(
          VehicleModel.fromJson(response.data as Map<String, dynamic>),
        );
      }
      throw const ApiException(message: 'Failed to update vehicle.');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  static Future<void> deleteVehicle(int vehicleId) async {
    try {
      await DioProvider.delete(endpoint: Apis.vehicleById(vehicleId));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Composed Vehicle Dashboard summary
  // ---------------------------------------------------------------------------

  static Future<VehicleDashboardData> fetchVehicleDashboard(
    int vehicleId,
  ) async {
    try {
      final results = await Future.wait<dynamic>([
        fetchVehicleById(vehicleId),
        DioProvider.get(endpoint: Apis.upcomingMaintenance(vehicleId)),
        DioProvider.get(endpoint: Apis.statisticsOverview(vehicleId)),
        DioProvider.get(endpoint: Apis.alerts(vehicleId)),
      ]);

      final vehicle = results[0] as VehicleModel;

      final upcomingResp = results[1] as Response<dynamic>;
      final upcomingItems = (upcomingResp.data is List)
          ? (upcomingResp.data as List)
              .map(
                (e) => UpcomingItemSummary.fromJson(e as Map<String, dynamic>),
              )
              .toList()
          : <UpcomingItemSummary>[];

      final overviewResp = results[2] as Response<dynamic>;
      final overview = (overviewResp.data is Map<String, dynamic>)
          ? VehicleOverviewStats.fromJson(
              overviewResp.data as Map<String, dynamic>,
            )
          : null;

      final alertsResp = results[3] as Response<dynamic>;
      var alertsCount = 0;
      if (alertsResp.data is Map<String, dynamic>) {
        final data = alertsResp.data as Map<String, dynamic>;
        final m = data['maintenance'] is List ? (data['maintenance'] as List).length : 0;
        final w = data['warranties'] is List ? (data['warranties'] as List).length : 0;
        alertsCount = m + w;
      }

      return VehicleDashboardData(
        vehicle: vehicle,
        upcomingItems: List.unmodifiable(upcomingItems),
        alertsCount: alertsCount,
        overview: overview,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
