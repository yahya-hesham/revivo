/// SVG icon asset paths extracted from Figma.
abstract final class AppAssets {
  static const String _iconsBase = 'assets/icons';

  // Navigation icons (Figma 8:2, 8:10, 8:18)
  static const String navGarage = '$_iconsBase/nav_garage.svg';
  static const String navAlerts = '$_iconsBase/nav_alerts.svg';
  static const String navAccount = '$_iconsBase/nav_account.svg';

  // Common icons
  static const String arrowBack = '$_iconsBase/arrow_back.svg';
  static const String chevronForward = '$_iconsBase/chevron_forward.svg';
  static const String settings = '$_iconsBase/settings.svg';
  static const String check = '$_iconsBase/check.svg';
  static const String add = '$_iconsBase/add.svg';
  static const String shield = '$_iconsBase/shield.svg';
  static const String navHome = '$_iconsBase/nav_home.svg';
  static const String navMaintenance = '$_iconsBase/nav_maintenance.svg';
  static const String navHistory = '$_iconsBase/nav_history.svg';
}

/// Alias kept for backwards compatibility with existing references.
typedef AppIcons = AppAssets;
