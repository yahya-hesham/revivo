import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/apis/api_error.dart';
import '../../data/models/maintenance_models.dart';
import '../../data/repository/maintenance_repo.dart';
import 'maintenance_history_state.dart';

class MaintenanceHistoryCubit extends Cubit<MaintenanceHistoryState> {
  MaintenanceHistoryCubit({
    Future<MaintenancePageModel> Function({
      required int vehicleId,
      int page,
      int pageSize,
    })? fetchPage,
    Future<List<MaintenanceStatusModel>> Function(int vehicleId)? fetchUpcoming,
    Future<List<MaintenanceStatusModel>> Function(int vehicleId)? fetchStatus,
  })  : _fetchPage = fetchPage ?? MaintenanceRepo.fetchMaintenancePage,
        _fetchUpcoming =
            fetchUpcoming ?? MaintenanceRepo.fetchUpcomingMaintenance,
        _fetchStatus = fetchStatus ?? MaintenanceRepo.fetchMaintenanceStatus,
        super(const MaintenanceHistoryInitial());

  final Future<MaintenancePageModel> Function({
    required int vehicleId,
    int page,
    int pageSize,
  }) _fetchPage;
  final Future<List<MaintenanceStatusModel>> Function(int vehicleId)
      _fetchUpcoming;
  final Future<List<MaintenanceStatusModel>> Function(int vehicleId)
      _fetchStatus;

  final List<MaintenanceRecordModel> _items = [];
  int _currentPage = 1;
  int _totalCount = 0;
  bool _hasMore = false;

  Future<void> loadHistory(int vehicleId) async {
    emit(const MaintenanceHistoryLoading());
    try {
      final page = await _fetchPage(vehicleId: vehicleId, page: 1);
      _items
        ..clear()
        ..addAll(page.items);
      _currentPage = page.page;
      _totalCount = page.totalCount;
      _hasMore = page.hasMore;
      if (!isClosed) {
        emit(
          MaintenanceHistoryLoaded(
            items: List.unmodifiable(_items),
            page: _currentPage,
            totalCount: _totalCount,
            hasMore: _hasMore,
          ),
        );
      }
    } on ApiException catch (e) {
      if (!isClosed) emit(MaintenanceHistoryError(e.message));
    } catch (_) {
      if (!isClosed) {
        emit(const MaintenanceHistoryError('Failed to load history.'));
      }
    }
  }

  Future<void> loadMore(int vehicleId) async {
    if (!_hasMore) return;
    final current = state;
    if (current is MaintenanceHistoryLoaded && current.isLoadingMore) return;

    emit(
      MaintenanceHistoryLoaded(
        items: List.unmodifiable(_items),
        page: _currentPage,
        totalCount: _totalCount,
        hasMore: _hasMore,
        isLoadingMore: true,
      ),
    );

    try {
      final next = await _fetchPage(
        vehicleId: vehicleId,
        page: _currentPage + 1,
      );
      _items.addAll(next.items);
      _currentPage = next.page;
      _totalCount = next.totalCount;
      _hasMore = next.hasMore;
      if (!isClosed) {
        emit(
          MaintenanceHistoryLoaded(
            items: List.unmodifiable(_items),
            page: _currentPage,
            totalCount: _totalCount,
            hasMore: _hasMore,
          ),
        );
      }
    } on ApiException catch (e) {
      if (!isClosed) emit(MaintenanceHistoryError(e.message));
    }
  }

  Future<void> loadUpcoming(int vehicleId) async {
    emit(const MaintenanceHistoryLoading());
    try {
      final results = await Future.wait<List<MaintenanceStatusModel>>([
        _fetchUpcoming(vehicleId),
        _fetchStatus(vehicleId),
      ]);
      if (!isClosed) {
        emit(
          MaintenanceStatusLoaded(
            upcoming: List.unmodifiable(results[0]),
            allStatuses: List.unmodifiable(results[1]),
          ),
        );
      }
    } on ApiException catch (e) {
      if (!isClosed) emit(MaintenanceHistoryError(e.message));
    } catch (_) {
      if (!isClosed) {
        emit(
          const MaintenanceHistoryError('Failed to load upcoming maintenance.'),
        );
      }
    }
  }
}
