/// Single source of truth for the Revivo API base URL and all 39 endpoints.
abstract final class Apis {
  /// Override at build/run time with `--dart-define=API_BASE_URL=...`.
  /// Defaults to the local HTTP backend profile (`http://localhost:5269`).
  /// For Android emulators, pass `--dart-define=API_BASE_URL=http://10.0.2.2:5269`.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5269',
  );

  // 1. Authentication
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String me = '/api/auth/me';

  // 2. Car catalog (public)
  static const String carMakes = '/api/car-catalog/makes';
  static const String carModels = '/api/car-catalog/models';
  static String carModelYears(int modelId) =>
      '/api/car-catalog/models/$modelId/years';
  static const String carImage = '/api/car-catalog/car-image';

  // 3. Vehicles (garage)
  static const String vehicles = '/api/vehicles';
  static const String sharedVehicles = '/api/vehicles/shared';
  static String vehicleById(int vehicleId) => '/api/vehicles/$vehicleId';

  // 4. Sharing & invitations
  static String vehicleShares(int vehicleId) =>
      '/api/vehicles/$vehicleId/shares';
  static String vehicleShareById(int vehicleId, int shareId) =>
      '/api/vehicles/$vehicleId/shares/$shareId';
  static const String vehicleInvitations = '/api/vehicle-invitations';
  static String acceptInvitation(int shareId) =>
      '/api/vehicle-invitations/$shareId/accept';
  static String rejectInvitation(int shareId) =>
      '/api/vehicle-invitations/$shareId/reject';

  // 5. Odometer
  static String odometer(int vehicleId) => '/api/vehicles/$vehicleId/odometer';
  static String odometerHistory(int vehicleId) =>
      '/api/vehicles/$vehicleId/odometer/history';

  // 6. Maintenance records
  static String maintenance(int vehicleId) =>
      '/api/vehicles/$vehicleId/maintenance';
  static String maintenanceById(int vehicleId, int recordId) =>
      '/api/vehicles/$vehicleId/maintenance/$recordId';

  // 7. Periodic maintenance (schedules)
  static String maintenanceSchedule(int vehicleId, int itemId) =>
      '/api/vehicles/$vehicleId/maintenance-items/$itemId/schedule';
  static String maintenanceStatus(int vehicleId) =>
      '/api/vehicles/$vehicleId/maintenance-status';
  static String upcomingMaintenance(int vehicleId) =>
      '/api/vehicles/$vehicleId/upcoming-maintenance';

  // 8. Warranties
  static String warranties(int vehicleId) =>
      '/api/vehicles/$vehicleId/warranties';
  static String recordWarranty(int vehicleId, int recordId) =>
      '/api/vehicles/$vehicleId/maintenance/$recordId/warranty';

  // 9. Notifications & alerts
  static String notificationSettings(int vehicleId) =>
      '/api/vehicles/$vehicleId/notification-settings';
  static String alerts(int vehicleId) => '/api/vehicles/$vehicleId/alerts';

  // 10. Statistics
  static String statisticsOverview(int vehicleId) =>
      '/api/vehicles/$vehicleId/statistics/overview';
  static String statisticsMileage(int vehicleId) =>
      '/api/vehicles/$vehicleId/statistics/mileage';
  static String statisticsExpenses(int vehicleId) =>
      '/api/vehicles/$vehicleId/statistics/expenses';
}
