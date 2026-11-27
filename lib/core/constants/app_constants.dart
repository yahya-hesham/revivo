import 'package:flutter/material.dart';

/// Design system spacing, radius, elevation, and sizing tokens (Revivo Figma).
abstract final class AppConstants {
  // Spacing Tokens (8px rhythm)
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;

  // Border Radius Tokens
  static const double radius12 = 12.0;
  static const double radius20 = 20.0;
  static const double radius28 = 28.0;

  static const BorderRadius borderRadius12 = BorderRadius.all(
    Radius.circular(radius12),
  );
  static const BorderRadius borderRadius20 = BorderRadius.all(
    Radius.circular(radius20),
  );
  static const BorderRadius borderRadius28 = BorderRadius.all(
    Radius.circular(radius28),
  );

  /// Revivo floating elevation.
  static const BoxShadow floatingShadow = BoxShadow(
    color: Color(0x1A0D1F1F),
    offset: Offset(0, 8),
    blurRadius: 24,
  );

  // Standard Layout & Component Sizes
  static const double touchTargetSize = 48.0;
  static const double buttonHeight = 56.0;
  static const double inputHeight = 84.0;
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 64.0;
  static const double dividerThickness = 1.0;

  // Standard Padding & EdgeInsets
  static const double screenHorizontalPadding = 24.0;
  static const double screenVerticalPadding = 16.0;
  static const double cardPadding = 16.0;
  static const double badgePadding = 8.0;

  static const EdgeInsets paddingAll8 = EdgeInsets.all(space8);
  static const EdgeInsets paddingAll16 = EdgeInsets.all(space16);
  static const EdgeInsets paddingAll24 = EdgeInsets.all(space24);

  static const EdgeInsets paddingH8 = EdgeInsets.symmetric(horizontal: space8);
  static const EdgeInsets paddingH16 = EdgeInsets.symmetric(
    horizontal: space16,
  );
  static const EdgeInsets paddingH24 = EdgeInsets.symmetric(
    horizontal: space24,
  );

  static const EdgeInsets paddingV8 = EdgeInsets.symmetric(vertical: space8);
  static const EdgeInsets paddingV16 = EdgeInsets.symmetric(vertical: space16);

  static const EdgeInsets paddingScreen = EdgeInsets.symmetric(
    horizontal: screenHorizontalPadding,
    vertical: screenVerticalPadding,
  );

  static const EdgeInsets paddingCard = EdgeInsets.all(cardPadding);
  static const EdgeInsets paddingBadge = EdgeInsets.all(badgePadding);
}
