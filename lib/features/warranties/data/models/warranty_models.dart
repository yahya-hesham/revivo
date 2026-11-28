/// Warranty DTO from `/api/vehicles/{vehicleId}/warranties` and
/// `/api/vehicles/{vehicleId}/maintenance/{recordId}/warranty`.
class WarrantyModel {
  const WarrantyModel({
    required this.maintenanceRecordId,
    required this.vehicleId,
    required this.itemId,
    required this.itemName,
    required this.durationMonths,
    required this.startDate,
    required this.expirationDate,
    required this.warningDays,
    required this.remainingDays,
    required this.status,
    required this.createdAt,
    this.provider,
    this.brand,
    this.notes,
  });

  final int maintenanceRecordId;
  final int vehicleId;
  final int itemId;
  final String itemName;
  final int durationMonths;
  final String startDate;
  final String expirationDate;
  final int warningDays;
  final int remainingDays;

  /// `Active`, `ExpiringSoon`, or `Expired`.
  final String status;
  final String? provider;
  final String? brand;
  final String? notes;
  final DateTime createdAt;

  factory WarrantyModel.fromJson(Map<String, dynamic> json) {
    return WarrantyModel(
      maintenanceRecordId: (json['maintenanceRecordId'] as num).toInt(),
      vehicleId: (json['vehicleId'] as num).toInt(),
      itemId: (json['itemId'] as num).toInt(),
      itemName: (json['itemName'] ?? '').toString(),
      durationMonths: (json['durationMonths'] as num).toInt(),
      startDate: (json['startDate'] ?? '').toString(),
      expirationDate: (json['expirationDate'] ?? '').toString(),
      warningDays: (json['warningDays'] as num?)?.toInt() ?? 30,
      remainingDays: (json['remainingDays'] as num?)?.toInt() ?? 0,
      status: (json['status'] ?? 'Active').toString(),
      provider: json['provider'] as String?,
      brand: json['brand'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now().toUtc(),
    );
  }
}

/// Request body for `PUT /api/vehicles/{vehicleId}/maintenance/{recordId}/warranty`.
class WarrantyRequestModel {
  const WarrantyRequestModel({
    required this.durationMonths,
    this.startDate,
    this.warningDays,
    this.provider,
    this.brand,
    this.notes,
  });

  final int durationMonths;

  /// Optional ISO date `YYYY-MM-DD`; null defaults to record's maintenance date.
  final String? startDate;
  final int? warningDays;
  final String? provider;
  final String? brand;
  final String? notes;

  Map<String, dynamic> toJson() {
    String? clean(String? v) {
      final t = v?.trim();
      return (t != null && t.isNotEmpty) ? t : null;
    }

    return {
      'durationMonths': durationMonths,
      'startDate': clean(startDate),
      'warningDays': warningDays,
      'provider': clean(provider),
      'brand': clean(brand),
      'notes': clean(notes),
    };
  }
}
