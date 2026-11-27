/// Declarative route path constants for Revivo.
abstract final class Routes {
  // Entry & authentication
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String sessionExpired = '/session-expired';

  // Authenticated main shell (Garage / Alerts / Account)
  static const String dashboard = '/dashboard';

  // Garage & vehicle flows
  static const String addVehicle = '/vehicles/add';
  static const String vehicleDashboard = '/vehicles/:vehicleId';
  static const String vehicleSettings = '/vehicles/:vehicleId/settings';

  // Maintenance & warranties
  static const String maintenanceHistory = '/vehicles/:vehicleId/maintenance';
  static const String recordMaintenance =
      '/vehicles/:vehicleId/maintenance/record';
  static const String maintenanceDetail =
      '/vehicles/:vehicleId/maintenance/:recordId';
  static const String editMaintenance =
      '/vehicles/:vehicleId/maintenance/:recordId/edit';
  static const String upcomingMaintenance =
      '/vehicles/:vehicleId/upcoming-maintenance';
  static const String warranties = '/vehicles/:vehicleId/warranties';
  static const String warrantyDetail =
      '/vehicles/:vehicleId/maintenance/:recordId/warranty';
  static const String warrantyForm =
      '/vehicles/:vehicleId/maintenance/:recordId/warranty/edit';

  // Odometer & statistics
  static const String updateOdometer = '/vehicles/:vehicleId/odometer/update';
  static const String odometerHistory = '/vehicles/:vehicleId/odometer/history';
  static const String spending = '/vehicles/:vehicleId/statistics/spending';
  static const String drivingInsights =
      '/vehicles/:vehicleId/statistics/driving';

  // Alerts & sharing
  static const String alertPreferences =
      '/vehicles/:vehicleId/alert-preferences';
  static const String shareVehicle = '/vehicles/:vehicleId/share';
  static const String manageAccess = '/vehicles/:vehicleId/access';
  static const String receivedInvitations = '/invitations';

  // Path builders for parameterized routes
  static String vehicleDashboardPath(int vehicleId) => '/vehicles/$vehicleId';
  static String vehicleSettingsPath(int vehicleId) =>
      '/vehicles/$vehicleId/settings';
  static String maintenanceHistoryPath(int vehicleId) =>
      '/vehicles/$vehicleId/maintenance';
  static String recordMaintenancePath(int vehicleId) =>
      '/vehicles/$vehicleId/maintenance/record';
  static String maintenanceDetailPath(int vehicleId, int recordId) =>
      '/vehicles/$vehicleId/maintenance/$recordId';
  static String editMaintenancePath(int vehicleId, int recordId) =>
      '/vehicles/$vehicleId/maintenance/$recordId/edit';
  static String upcomingMaintenancePath(int vehicleId) =>
      '/vehicles/$vehicleId/upcoming-maintenance';
  static String warrantiesPath(int vehicleId) =>
      '/vehicles/$vehicleId/warranties';
  static String warrantyDetailPath(int vehicleId, int recordId) =>
      '/vehicles/$vehicleId/maintenance/$recordId/warranty';
  static String warrantyFormPath(int vehicleId, int recordId) =>
      '/vehicles/$vehicleId/maintenance/$recordId/warranty/edit';
  static String updateOdometerPath(int vehicleId) =>
      '/vehicles/$vehicleId/odometer/update';
  static String odometerHistoryPath(int vehicleId) =>
      '/vehicles/$vehicleId/odometer/history';
  static String spendingPath(int vehicleId) =>
      '/vehicles/$vehicleId/statistics/spending';
  static String drivingInsightsPath(int vehicleId) =>
      '/vehicles/$vehicleId/statistics/driving';
  static String alertPreferencesPath(int vehicleId) =>
      '/vehicles/$vehicleId/alert-preferences';
  static String shareVehiclePath(int vehicleId) =>
      '/vehicles/$vehicleId/share';
  static String manageAccessPath(int vehicleId) =>
      '/vehicles/$vehicleId/access';
}
