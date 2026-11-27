/// Car manufacturer from `GET /api/car-catalog/makes`.
class CarMakeModel {
  const CarMakeModel({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory CarMakeModel.fromJson(Map<String, dynamic> json) {
    return CarMakeModel(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
    );
  }
}

/// Car model from `GET /api/car-catalog/models?makeId=`.
class CarModelItem {
  const CarModelItem({
    required this.id,
    required this.carMakeId,
    required this.name,
    this.yearStart,
    this.yearEnd,
  });

  final int id;
  final int carMakeId;
  final String name;
  final int? yearStart;
  final int? yearEnd;

  factory CarModelItem.fromJson(Map<String, dynamic> json) {
    return CarModelItem(
      id: (json['id'] as num).toInt(),
      carMakeId: (json['carMakeId'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      yearStart: (json['yearStart'] as num?)?.toInt(),
      yearEnd: (json['yearEnd'] as num?)?.toInt(),
    );
  }
}

/// Illustrative vehicle photo lookup from `GET /api/car-catalog/car-image`.
/// Always returns HTTP 200 with `status` in:
/// `found`, `noImage`, `rateLimited`, `notConfigured`, `unavailable`.
class CarImageModel {
  const CarImageModel({
    required this.status,
    required this.isExactVehicle,
    required this.message,
    this.imageUrl,
    this.photographerName,
    this.photographerUrl,
    this.photoUrl,
    this.unsplashUrl,
  });

  final String status;
  final String? imageUrl;
  final String? photographerName;
  final String? photographerUrl;
  final String? photoUrl;
  final String? unsplashUrl;
  final bool isExactVehicle;
  final String message;

  bool get isFound =>
      status.toLowerCase() == 'found' &&
      imageUrl != null &&
      imageUrl!.isNotEmpty;

  factory CarImageModel.fromJson(Map<String, dynamic> json) {
    return CarImageModel(
      status: (json['status'] ?? 'unavailable').toString(),
      imageUrl: json['imageUrl'] as String?,
      photographerName: json['photographerName'] as String?,
      photographerUrl: json['photographerUrl'] as String?,
      photoUrl: json['photoUrl'] as String?,
      unsplashUrl: json['unsplashUrl'] as String?,
      isExactVehicle: (json['isExactVehicle'] as bool?) ?? false,
      message: (json['message'] ?? '').toString(),
    );
  }
}
