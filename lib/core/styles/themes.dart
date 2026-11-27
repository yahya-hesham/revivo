import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import 'colors.dart';
import 'text_styles.dart';

/// Material [TextTheme] and [ThemeData] built from Revivo Figma design tokens.
abstract final class AppTextTheme {
  static TextTheme lightTextTheme({bool isArabic = false}) {
    if (isArabic) {
      return TextTheme(
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

    return TextTheme(
      displayLarge: AppTextStyles.display,
      headlineLarge: AppTextStyles.title,
      headlineMedium: AppTextStyles.title,
      titleLarge: AppTextStyles.heading,
      titleMedium: AppTextStyles.label,
      bodyLarge: AppTextStyles.body,
      bodyMedium: AppTextStyles.label,
      bodySmall: AppTextStyles.caption,
      labelLarge: AppTextStyles.label,
      labelSmall: AppTextStyles.caption,
    );
  }

  static TextTheme darkTextTheme({bool isArabic = false}) {
    final base = lightTextTheme(isArabic: isArabic);
    return base.apply(
      bodyColor: AppColors.darkInk,
      displayColor: AppColors.darkInk,
    );
  }
}

abstract final class AppThemes {
  static ThemeData lightTheme({bool isArabic = false}) {
    final textTheme = AppTextTheme.lightTextTheme(isArabic: isArabic);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.ground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.teal,
        onPrimary: AppColors.onBrand,
        secondary: AppColors.accent,
        onSecondary: AppColors.ink,
        surface: AppColors.surface,
        onSurface: AppColors.ink,
        onSurfaceVariant: AppColors.muted,
        error: AppColors.red,
        onError: AppColors.white,
        outline: AppColors.line,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.ground,
        foregroundColor: AppColors.ink,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppConstants.borderRadius20,
          side: BorderSide(color: AppColors.line),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.space16,
          vertical: AppConstants.space16,
        ),
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.muted),
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.red),
        border: OutlineInputBorder(
          borderRadius: AppConstants.borderRadius12,
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppConstants.borderRadius12,
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppConstants.borderRadius12,
          borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppConstants.borderRadius12,
          borderSide: const BorderSide(color: AppColors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppConstants.borderRadius12,
          borderSide: const BorderSide(color: AppColors.red, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: AppColors.onBrand,
          minimumSize: const Size(double.infinity, AppConstants.buttonHeight),
          shape: const RoundedRectangleBorder(
            borderRadius: AppConstants.borderRadius20,
          ),
          elevation: 0,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.ink,
          minimumSize: const Size(double.infinity, AppConstants.buttonHeight),
          side: BorderSide.none,
          shape: const RoundedRectangleBorder(
            borderRadius: AppConstants.borderRadius20,
          ),
          elevation: 0,
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.teal,
          minimumSize: const Size(
            AppConstants.touchTargetSize,
            AppConstants.touchTargetSize,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: AppConstants.dividerThickness,
        space: 1,
      ),
    );
  }

  static ThemeData darkTheme({bool isArabic = false}) {
    final textTheme = AppTextTheme.darkTextTheme(isArabic: isArabic);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkGround,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        onPrimary: AppColors.ink,
        secondary: AppColors.teal,
        onSecondary: AppColors.onBrand,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkInk,
        onSurfaceVariant: AppColors.darkMuted,
        error: AppColors.red,
        onError: AppColors.white,
        outline: Color(0xFF2B4245),
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkGround,
        foregroundColor: AppColors.darkInk,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppConstants.borderRadius20,
          side: BorderSide(color: Color(0xFF2B4245)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.space16,
          vertical: AppConstants.space16,
        ),
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.darkMuted),
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.redSoft),
        border: OutlineInputBorder(
          borderRadius: AppConstants.borderRadius12,
          borderSide: const BorderSide(color: Color(0xFF2B4245)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppConstants.borderRadius12,
          borderSide: const BorderSide(color: Color(0xFF2B4245)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppConstants.borderRadius12,
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppConstants.borderRadius12,
          borderSide: const BorderSide(color: AppColors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppConstants.borderRadius12,
          borderSide: const BorderSide(color: AppColors.red, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.ink,
          minimumSize: const Size(double.infinity, AppConstants.buttonHeight),
          shape: const RoundedRectangleBorder(
            borderRadius: AppConstants.borderRadius20,
          ),
          elevation: 0,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.darkSurface,
          foregroundColor: AppColors.darkInk,
          minimumSize: const Size(double.infinity, AppConstants.buttonHeight),
          side: BorderSide.none,
          shape: const RoundedRectangleBorder(
            borderRadius: AppConstants.borderRadius20,
          ),
          elevation: 0,
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          minimumSize: const Size(
            AppConstants.touchTargetSize,
            AppConstants.touchTargetSize,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2B4245),
        thickness: AppConstants.dividerThickness,
        space: 1,
      ),
    );
  }
}
