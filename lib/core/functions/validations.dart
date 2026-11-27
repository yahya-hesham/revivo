/// Pure form-field validators aligned with Revivo backend rules.
abstract final class AppValidations {
  static final RegExp _emailRegex = RegExp(
    r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
  );

  static String? requiredText(
    String? value, {
    String fieldName = 'This field',
    int maxLength = 100,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return '$fieldName is required.';
    if (trimmed.length > maxLength) {
      return '$fieldName must be at most $maxLength characters.';
    }
    return null;
  }

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Email is required.';
    if (trimmed.length > 256 || !_emailRegex.hasMatch(trimmed)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    return null;
  }

  /// ASP.NET Core Identity default password requirements:
  /// 6+ characters, uppercase, lowercase, digit, and non-alphanumeric symbol.
  static String? registerPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value) ||
        !RegExp(r'[a-z]').hasMatch(value) ||
        !RegExp(r'[0-9]').hasMatch(value) ||
        !RegExp(r'[^A-Za-z0-9]').hasMatch(value)) {
      return 'Use uppercase, lowercase, a number, and a symbol.';
    }
    return null;
  }

  static String? mileage(String? value, {int minMileage = 0}) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Mileage is required.';
    final parsed = int.tryParse(trimmed);
    if (parsed == null) return 'Enter a valid whole number.';
    if (parsed < minMileage) {
      return minMileage == 0
          ? 'Mileage cannot be negative.'
          : 'Mileage cannot be less than $minMileage km.';
    }
    return null;
  }

  static String? costEgp(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Cost is required.';
    final parsed = double.tryParse(trimmed);
    if (parsed == null || parsed < 0) {
      return 'Enter a valid non-negative amount.';
    }
    return null;
  }
}
