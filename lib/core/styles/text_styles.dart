import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Typography styles extracted directly from Figma Design System (Revivo).
abstract final class AppTextStyles {
  // ---------------------------------------------------------------------------
  // English Styles (Geist)
  // ---------------------------------------------------------------------------

  /// Number: Geist Medium, 32px, Line Height 40px (1.25)
  static TextStyle get number => GoogleFonts.geist(
        fontSize: 32,
        fontWeight: FontWeight.w500,
        height: 40 / 32,
        color: AppColors.ink,
      );

  /// Brand: Geist SemiBold, 28px, Line Height 32px (1.14)
  static TextStyle get brand => GoogleFonts.geist(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 32 / 28,
        color: AppColors.ink,
      );

  /// Title: Geist Medium, 24px, Line Height 32px (1.33)
  static TextStyle get title => GoogleFonts.geist(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        height: 32 / 24,
        color: AppColors.ink,
      );

  /// Section: Geist Medium, 18px, Line Height 24px (1.33)
  static TextStyle get section => GoogleFonts.geist(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 24 / 18,
        color: AppColors.ink,
      );

  /// Body: Geist Regular, 16px, Line Height 24px (1.50)
  static TextStyle get body => GoogleFonts.geist(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: AppColors.ink,
      );

  /// Label: Geist Medium, 14px, Line Height 24px (1.71)
  static TextStyle get label => GoogleFonts.geist(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 24 / 14,
        color: AppColors.ink,
      );

  /// Caption: Geist Regular, 12px, Line Height 16px (1.33)
  static TextStyle get caption => GoogleFonts.geist(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 16 / 12,
        color: AppColors.muted,
      );

  // ---------------------------------------------------------------------------
  // Arabic Styles (Noto Sans Arabic)
  // ---------------------------------------------------------------------------

  /// Arabic Number: Noto Sans Arabic Medium, 32px, Line Height 48px (1.50)
  static TextStyle get arNumber => GoogleFonts.notoSansArabic(
        fontSize: 32,
        fontWeight: FontWeight.w500,
        height: 48 / 32,
        color: AppColors.ink,
      );

  /// Arabic Brand: Noto Sans Arabic SemiBold, 28px, Line Height 40px (1.43)
  static TextStyle get arBrand => GoogleFonts.notoSansArabic(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 40 / 28,
        color: AppColors.ink,
      );

  /// Arabic Title: Noto Sans Arabic Medium, 24px, Line Height 40px (1.67)
  static TextStyle get arTitle => GoogleFonts.notoSansArabic(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        height: 40 / 24,
        color: AppColors.ink,
      );

  /// Arabic Section: Noto Sans Arabic Medium, 18px, Line Height 32px (1.78)
  static TextStyle get arSection => GoogleFonts.notoSansArabic(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 32 / 18,
        color: AppColors.ink,
      );

  /// Arabic Body: Noto Sans Arabic Regular, 16px, Line Height 32px (2.00)
  static TextStyle get arBody => GoogleFonts.notoSansArabic(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 32 / 16,
        color: AppColors.ink,
      );

  /// Arabic Label: Noto Sans Arabic Medium, 14px, Line Height 32px (2.29)
  static TextStyle get arLabel => GoogleFonts.notoSansArabic(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 32 / 14,
        color: AppColors.ink,
      );

  /// Arabic Caption: Noto Sans Arabic Regular, 12px, Line Height 24px (2.00)
  static TextStyle get arCaption => GoogleFonts.notoSansArabic(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 24 / 12,
        color: AppColors.muted,
      );
}

