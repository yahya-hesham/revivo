/// Completed maintenance record from `/api/vehicles/{vehicleId}/maintenance`.
class MaintenanceRecordModel {
  const MaintenanceRecordModel({
    required this.id,
    required this.vehicleId,
    required this.itemId,
    required this.category,
    required this.itemName,
    required this.maintenanceDate,
    required this.mileageKm,
    required this.costEgp,
    required this.createdAt,
    this.notes,
  });

  final int id;
  final int vehicleId;
  final int itemId;
  final String category;
  final String itemName;

  /// ISO date `YYYY-MM-DD`.
  final String maintenanceDate;
  final int mileageKm;
  final double costEgp;
  final String? notes;
  final DateTime createdAt;

  factory MaintenanceRecordModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceRecordModel(
      id: (json['id'] as num).toInt(),
      vehicleId: (json['vehicleId'] as num).toInt(),
      itemId: (json['itemId'] as num).toInt(),
      category: (json['category'] ?? '').toString(),
      itemName: (json['itemName'] ?? '').toString(),
      maintenanceDate: (json['maintenanceDate'] ?? '').toString(),
      mileageKm: (json['mileageKm'] as num).toInt(),
      costEgp: (json['costEgp'] as num).toDouble(),
      notes: json['notes'] as String?,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now().toUtc(),
    );
  }
}

/// Paginated response from `GET /api/vehicles/{vehicleId}/maintenance`.
class MaintenancePageModel {
  const MaintenancePageModel({
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.items,
  });

  final int page;
  final int pageSize;
  final int totalCount;
  final List<MaintenanceRecordModel> items;

  bool get hasMore => page * pageSize < totalCount;

  factory MaintenancePageModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] is List ? json['items'] as List : const [];
    return MaintenancePageModel(
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 20,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? rawItems.length,
      items: rawItems
          .map(
            (e) => MaintenanceRecordModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

/// Request body for `POST/PUT /api/vehicles/{vehicleId}/maintenance`.
class MaintenanceRequestModel {
  const MaintenanceRequestModel({
    required this.category,
    required this.itemName,
    required this.maintenanceDate,
    required this.mileageKm,
    required this.costEgp,
    this.notes,
  });

  final String category;
  final String itemName;

  /// ISO date `YYYY-MM-DD`.
  final String maintenanceDate;
  final int mileageKm;
  final double costEgp;
  final String? notes;

  Map<String, dynamic> toJson() {
    final trimmedNotes = notes?.trim();
    return {
      'category': category.trim(),
      'itemName': itemName.trim(),
      'maintenanceDate': maintenanceDate,
      'mileageKm': mileageKm,
      'costEgp': double.parse(costEgp.toStringAsFixed(2)),
      'notes': (trimmedNotes != null && trimmedNotes.isNotEmpty)
          ? trimmedNotes
          : null,
    };
  }
}

/// Request body for `PUT /api/vehicles/{vehicleId}/maintenance-items/{itemId}/schedule`.
class ScheduleRequestModel {
  const ScheduleRequestModel({
    this.intervalKm,
    this.intervalMonths,
    this.warningKm,
    this.warningDays,
  });

  final int? intervalKm;
  final int? intervalMonths;
  final int? warningKm;
  final int? warningDays;

  Map<String, dynamic> toJson() => {
        'intervalKm': intervalKm,
        'intervalMonths': intervalMonths,
        'warningKm': warningKm,
        'warningDays': warningDays,
      };
}

/// Backend-calculated maintenance status from `/maintenance-status`,
/// `/upcoming-maintenance`, and `PUT .../schedule`.
class MaintenanceStatusModel {
  const MaintenanceStatusModel({
    required this.itemId,
    required this.category,
    required this.itemName,
    required this.warningKm,
    required this.warningDays,
    required this.status,
    this.intervalKm,
    this.intervalMonths,
    this.lastMaintenanceDate,
    this.lastMaintenanceMileage,
    this.nextDueDate,
    this.nextDueMileageKm,
    this.remainingDays,
    this.remainingKm,
  });

  final int itemId;
  final String category;
  final String itemName;
  final int? intervalKm;
  final int? intervalMonths;
  final int warningKm;
  final int warningDays;
  final String? lastMaintenanceDate;
  final int? lastMaintenanceMileage;
  final String? nextDueDate;
  final int? nextDueMileageKm;
  final int? remainingDays;
  final int? remainingKm;

  /// `OnTrack`, `DueSoon`, or `Overdue`.
  final String status;

  bool get hasNextDue => nextDueDate != null || nextDueMileageKm != null;

  factory MaintenanceStatusModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceStatusModel(
      itemId: (json['itemId'] as num).toInt(),
      category: (json['category'] ?? '').toString(),
      itemName: (json['itemName'] ?? '').toString(),
      intervalKm: (json['intervalKm'] as num?)?.toInt(),
      intervalMonths: (json['intervalMonths'] as num?)?.toInt(),
      warningKm: (json['warningKm'] as num?)?.toInt() ?? 1000,
      warningDays: (json['warningDays'] as num?)?.toInt() ?? 30,
      lastMaintenanceDate: json['lastMaintenanceDate'] as String?,
      lastMaintenanceMileage: (json['lastMaintenanceMileage'] as num?)?.toInt(),
      nextDueDate: json['nextDueDate'] as String?,
      nextDueMileageKm: (json['nextDueMileageKm'] as num?)?.toInt(),
      remainingDays: (json['remainingDays'] as num?)?.toInt(),
      remainingKm: (json['remainingKm'] as num?)?.toInt(),
      status: (json['status'] ?? 'OnTrack').toString(),
    );
  }
}
