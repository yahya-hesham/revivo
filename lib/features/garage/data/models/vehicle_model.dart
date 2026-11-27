/// Vehicle DTO returned by `/api/vehicles`, `/api/vehicles/{id}`, and `/api/vehicles/shared`.
/// Note: backend DTO does not carry make/model names; [displayModelName] is resolved from catalog.
class VehicleModel {
  const VehicleModel({
    required this.id,
    required this.ownerId,
    required this.carModelId,
    required this.year,
    required this.currentMileageKm,
    required this.createdAt,
    this.nickname,
    this.imageUrl,
    this.makeName,
    this.modelName,
    this.isShared = false,
  });

  final int id;
  final String ownerId;
  final int carModelId;
  final int year;
  final int currentMileageKm;
  final String? nickname;
  final String? imageUrl;
  final DateTime createdAt;

  /// Resolved from car catalog (nullable if not yet resolved).
  final String? makeName;
  final String? modelName;

  /// True when fetched from `/api/vehicles/shared` or `ownerId != currentUser.id`.
  final bool isShared;

  String get catalogTitle {
    final parts = [
      if (makeName != null && makeName!.isNotEmpty) makeName!,
      if (modelName != null && modelName!.isNotEmpty) modelName!,
    ];
    if (parts.isNotEmpty) return parts.join(' ');
    return 'Vehicle #$id';
  }

  String get displayTitle {
    final nick = nickname?.trim();
    if (nick != null && nick.isNotEmpty) return nick;
    return catalogTitle;
  }

  VehicleModel copyWith({
    String? makeName,
    String? modelName,
    bool? isShared,
  }) {
    return VehicleModel(
      id: id,
      ownerId: ownerId,
      carModelId: carModelId,
      year: year,
      currentMileageKm: currentMileageKm,
      createdAt: createdAt,
      nickname: nickname,
      imageUrl: imageUrl,
      makeName: makeName ?? this.makeName,
      modelName: modelName ?? this.modelName,
      isShared: isShared ?? this.isShared,
    );
  }

  factory VehicleModel.fromJson(
    Map<String, dynamic> json, {
    bool isShared = false,
  }) {
    return VehicleModel(
      id: (json['id'] as num).toInt(),
      ownerId: (json['ownerId'] ?? '').toString(),
      carModelId: (json['carModelId'] as num).toInt(),
      year: (json['year'] as num).toInt(),
      currentMileageKm: (json['currentMileageKm'] as num).toInt(),
      nickname: json['nickname'] as String?,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now().toUtc(),
      isShared: isShared,
    );
  }
}

/// Request body for `POST /api/vehicles` and `PUT /api/vehicles/{id}`.
class VehicleRequestModel {
  const VehicleRequestModel({
    required this.carModelId,
    required this.year,
    required this.currentMileageKm,
    this.nickname,
    this.imageUrl,
  });

  final int carModelId;
  final int year;
  final int currentMileageKm;
  final String? nickname;
  final String? imageUrl;

  Map<String, dynamic> toJson() {
    final trimmedNick = nickname?.trim();
    final trimmedImage = imageUrl?.trim();
    return {
      'carModelId': carModelId,
      'year': year,
      'currentMileageKm': currentMileageKm,
      'nickname': (trimmedNick != null && trimmedNick.isNotEmpty)
          ? trimmedNick
          : null,
      'imageUrl': (trimmedImage != null && trimmedImage.isNotEmpty)
          ? trimmedImage
          : null,
    };
  }
}

/// Lightweight upcoming item summary for the Vehicle Dashboard.
class UpcomingItemSummary {
  const UpcomingItemSummary({
    required this.itemId,
    required this.category,
    required this.itemName,
    required this.status,
    this.nextDueDate,
    this.nextDueMileageKm,
    this.remainingDays,
    this.remainingKm,
  });

  final int itemId;
  final String category;
  final String itemName;
  final String status;
  final String? nextDueDate;
  final int? nextDueMileageKm;
  final int? remainingDays;
  final int? remainingKm;

  factory UpcomingItemSummary.fromJson(Map<String, dynamic> json) {
    return UpcomingItemSummary(
      itemId: (json['itemId'] as num).toInt(),
      category: (json['category'] ?? '').toString(),
      itemName: (json['itemName'] ?? '').toString(),
      status: (json['status'] ?? 'OnTrack').toString(),
      nextDueDate: json['nextDueDate'] as String?,
      nextDueMileageKm: (json['nextDueMileageKm'] as num?)?.toInt(),
      remainingDays: (json['remainingDays'] as num?)?.toInt(),
      remainingKm: (json['remainingKm'] as num?)?.toInt(),
    );
  }
}

/// Lightweight overview statistics summary for the Vehicle Dashboard.
class VehicleOverviewStats {
  const VehicleOverviewStats({
    required this.currentMileageKm,
    required this.lifetimeMaintenanceCost,
    required this.thisMonthMaintenanceCost,
    required this.thisYearMaintenanceCost,
    required this.maintenanceOperationsCount,
    required this.currency,
    this.thisMonthDistanceKm,
    this.thisMonthDistanceStatus = 'Unavailable',
  });

  final int currentMileageKm;
  final double? thisMonthDistanceKm;
  final String thisMonthDistanceStatus;
  final double lifetimeMaintenanceCost;
  final double thisMonthMaintenanceCost;
  final double thisYearMaintenanceCost;
  final int maintenanceOperationsCount;
  final String currency;

  factory VehicleOverviewStats.fromJson(Map<String, dynamic> json) {
    return VehicleOverviewStats(
      currentMileageKm: (json['currentMileageKm'] as num?)?.toInt() ?? 0,
      thisMonthDistanceKm: (json['thisMonthDistanceKm'] as num?)?.toDouble(),
      thisMonthDistanceStatus:
          (json['thisMonthDistanceStatus'] ?? 'Unavailable').toString(),
      lifetimeMaintenanceCost:
          (json['lifetimeMaintenanceCost'] as num?)?.toDouble() ?? 0,
      thisMonthMaintenanceCost:
          (json['thisMonthMaintenanceCost'] as num?)?.toDouble() ?? 0,
      thisYearMaintenanceCost:
          (json['thisYearMaintenanceCost'] as num?)?.toDouble() ?? 0,
      maintenanceOperationsCount:
          (json['maintenanceOperationsCount'] as num?)?.toInt() ?? 0,
      currency: (json['currency'] ?? 'EGP').toString(),
    );
  }
}

/// Composed payload for the Vehicle Dashboard screen (`3:288`).
class VehicleDashboardData {
  const VehicleDashboardData({
    required this.vehicle,
    required this.upcomingItems,
    required this.alertsCount,
    this.overview,
  });

  final VehicleModel vehicle;
  final List<UpcomingItemSummary> upcomingItems;
  final int alertsCount;
  final VehicleOverviewStats? overview;
}
