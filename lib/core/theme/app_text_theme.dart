import 'package:flutter/material.dart';
import '../styles/text_styles.dart';

/// Flutter Material [TextTheme] mapped directly from Figma Design Tokens.
abstract final class AppTextTheme {
  /// English [TextTheme] based on Geist font family
  static TextTheme get lightTextTheme => TextTheme(
        displayLarge: AppTextStyles.number,
        headlineLarge: AppTextStyles.brand,
        headlineMedium: AppTextStyles.title,
        titleLarge: AppTextStyles.section,
        titleMedium: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.label,
        bodySmall: AppTextStyles.caption,
        labelLarge: AppTextStyles.label,
        labelSmall: AppTextStyles.caption,
      );

  /// Arabic [TextTheme] based on Noto Sans Arabic font family
  static TextTheme get arabicLightTextTheme => TextTheme(
        displayLarge: AppTextStyles.arNumber,
        headlineLarge: AppTextStyles.arBrand,
        headlineMedium: AppTextStyles.arTitle,
        titleLarge: AppTextStyles.arSection,
        titleMedium: AppTextStyles.arBody.copyWith(fontWeight: FontWeight.w500),
        bodyLarge: AppTextStyles.arBody,
        bodyMedium: AppTextStyles.arLabel,
        bodySmall: AppTextStyles.arCaption,
        labelLarge: AppTextStyles.arLabel,
        labelSmall: AppTextStyles.arCaption,
      );
}

