import 'package:flutter/material.dart';

/// App color palette extracted from Figma Design System (Revivo).
abstract final class AppColors {
  // Brand / Primary Colors
  static const Color teal = Color(0xFF123C3B);
  static const Color accent = Color(0xFFD9F279);
  static const Color onBrand = Color(0xFFFFFFFF);
  static const Color tealSoft = Color(0xFFE9F3EF);
  static const Color pressed = Color(0xFF1B5149);

  // Background & Surface Colors
  static const Color ground = Color(0xFFF6F5F0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color soft = Color(0xFFF0EFEB);

  // Neutrals & Typography Colors
  static const Color ink = Color(0xFF152C2D);
  static const Color muted = Color(0xFF5E7170);
  static const Color line = Color(0xFFDCE3DE);
  static const Color control = Color(0xFF9BACA7);
  static const Color white = Color(0xFFFFFFFF);

  // Semantic & Feedback Colors
  static const Color success = Color(0xFF25634F);
  static const Color successSoft = Color(0xFFE8F2EC);
  static const Color amber = Color(0xFF8B510E);
  static const Color amberSoft = Color(0xFFFFF1D9);
  static const Color red = Color(0xFFAA3530);
  static const Color redSoft = Color(0xFFFCECE8);

  // Dashboard dark mode overrides
  static const Color darkGround = Color(0xFF101E20);
  static const Color darkSurface = Color(0xFF1B2E30);
  static const Color darkInk = Color(0xFFE9F0E9);
  static const Color darkMuted = Color(0xFFACBDB8);

  // Material 3 System Schemes
  static const Color onSurface = Color(0xFF1D1B20);
}

/// Alias for backwards compatibility with the initial placeholder class
typedef Colors = AppColors;
