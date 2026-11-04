import 'package:flutter/material.dart';

/// App color palette extracted from Figma Design System (Revivo).
abstract final class AppColors {
  // Brand / Primary Colors
  static const Color teal = Color(0xFF286B61);
  static const Color tealSoft = Color(0xFFE9F3EF);
  static const Color pressed = Color(0xFF1B5149);

  // Background & Surface Colors
  static const Color ground = Color(0xFFFAF9F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color soft = Color(0xFFF0EFEB);

  // Neutrals & Typography Colors
  static const Color ink = Color(0xFF242A29);
  static const Color muted = Color(0xFF626966);
  static const Color line = Color(0xFFE6E7E2);
  static const Color control = Color(0xFF9BACA7);
  static const Color white = Color(0xFFFFFFFF);

  // Semantic & Feedback Colors
  static const Color amber = Color(0xFF8A570A);
  static const Color amberSoft = Color(0xFFFFF3DB);
  static const Color red = Color(0xFFB43B37);
  static const Color redSoft = Color(0xFFFCECEA);

  // Material 3 System Schemes
  static const Color onSurface = Color(0xFF1D1B20);
}

/// Alias for backwards compatibility with the initial placeholder class
typedef Colors = AppColors;
