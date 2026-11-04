import 'package:flutter/material.dart';

/// Design system constants extracted from Figma (Revivo).
abstract final class AppConstants {
  // ---------------------------------------------------------------------------
  // Spacing Tokens (space/*)
  // ---------------------------------------------------------------------------
  static const double space8 = 8.0;
  static const double space16 = 16.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space48 = 48.0;

  // ---------------------------------------------------------------------------
  // Border Radius Tokens (radius/*)
  // ---------------------------------------------------------------------------
  static const double radius8 = 8.0;
  static const double radius16 = 16.0;
  static const double radius24 = 24.0;

  static const BorderRadius borderRadius8 = BorderRadius.all(Radius.circular(radius8));
  static const BorderRadius borderRadius16 = BorderRadius.all(Radius.circular(radius16));
  static const BorderRadius borderRadius24 = BorderRadius.all(Radius.circular(radius24));

  // ---------------------------------------------------------------------------
  // Standard Layout & Component Sizes
  // ---------------------------------------------------------------------------
  /// Standard touch target minimum size (size/touch)
  static const double touchTargetSize = 48.0;

  /// Standard button height
  static const double buttonHeight = 56.0;

  /// Standard text field height
  static const double inputHeight = 56.0;

  /// Standard app bar height
  static const double appBarHeight = 56.0;

  /// System status bar height in designs
  static const double statusBarHeight = 48.0;

  /// Bottom navigation bar height
  static const double bottomNavHeight = 80.0;

  /// System gesture navigation bar
  static const double gestureBarWidth = 134.0;
  static const double gestureBarHeight = 5.0;

  /// Divider line thickness
  static const double dividerThickness = 1.0;

  // ---------------------------------------------------------------------------
  // Standard Padding & EdgeInsets
  // ---------------------------------------------------------------------------
  static const double screenHorizontalPadding = 24.0;
  static const double screenVerticalPadding = 16.0;
  static const double cardPadding = 16.0;
  static const double badgePadding = 8.0;

  static const EdgeInsets paddingAll8 = EdgeInsets.all(space8);
  static const EdgeInsets paddingAll16 = EdgeInsets.all(space16);
  static const EdgeInsets paddingAll24 = EdgeInsets.all(space24);

  static const EdgeInsets paddingH8 = EdgeInsets.symmetric(horizontal: space8);
  static const EdgeInsets paddingH16 = EdgeInsets.symmetric(horizontal: space16);
  static const EdgeInsets paddingH24 = EdgeInsets.symmetric(horizontal: space24);

  static const EdgeInsets paddingV8 = EdgeInsets.symmetric(vertical: space8);
  static const EdgeInsets paddingV16 = EdgeInsets.symmetric(vertical: space16);

  static const EdgeInsets paddingScreen = EdgeInsets.symmetric(
    horizontal: screenHorizontalPadding,
    vertical: screenVerticalPadding,
  );

  static const EdgeInsets paddingCard = EdgeInsets.all(cardPadding);
  static const EdgeInsets paddingBadge = EdgeInsets.all(badgePadding);
}

