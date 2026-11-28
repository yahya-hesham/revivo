import '../../data/models/maintenance_models.dart';

abstract class MaintenanceHistoryState {
  const MaintenanceHistoryState();
}

class MaintenanceHistoryInitial extends MaintenanceHistoryState {
  const MaintenanceHistoryInitial();
}

class MaintenanceHistoryLoading extends MaintenanceHistoryState {
  const MaintenanceHistoryLoading();
}

class MaintenanceHistoryLoaded extends MaintenanceHistoryState {
  const MaintenanceHistoryLoaded({
    required this.items,
    required this.page,
    required this.totalCount,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  final List<MaintenanceRecordModel> items;
  final int page;
  final int totalCount;
  final bool hasMore;
  final bool isLoadingMore;
}

class MaintenanceStatusLoaded extends MaintenanceHistoryState {
  const MaintenanceStatusLoaded({
    required this.upcoming,
    required this.allStatuses,
  });

  final List<MaintenanceStatusModel> upcoming;
  final List<MaintenanceStatusModel> allStatuses;
}

class MaintenanceHistoryError extends MaintenanceHistoryState {
  const MaintenanceHistoryError(this.message);

  final String message;
}
