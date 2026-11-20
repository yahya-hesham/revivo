import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Typography styles extracted directly from Figma Design System (Revivo).
abstract final class AppTextStyles {
  // ---------------------------------------------------------------------------
  // English Styles (Manrope)
  // ---------------------------------------------------------------------------

  /// Revivo/Display
  static TextStyle get display => GoogleFonts.manrope(
        fontSize: 38,
        fontWeight: FontWeight.w700,
        height: 44 / 38,
        letterSpacing: 0,
        color: AppColors.ink,
      );

  /// Revivo/Title
  static TextStyle get title => GoogleFonts.manrope(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 34 / 28,
        letterSpacing: 0,
        color: AppColors.ink,
      );

  /// Revivo/Heading
  static TextStyle get heading => GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 28 / 20,
        letterSpacing: 0,
        color: AppColors.ink,
      );

  /// Revivo/Body
  static TextStyle get body => GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        letterSpacing: 0,
        color: AppColors.ink,
      );

  /// Revivo/Label
  static TextStyle get label => GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 22 / 15,
        letterSpacing: 0,
        color: AppColors.ink,
      );

  /// Revivo/Caption
  static TextStyle get caption => GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 18 / 12,
        letterSpacing: 0,
        color: AppColors.muted,
      );

  @Deprecated('Use display for the current English typography.')
  static TextStyle get number => display;

  @Deprecated('Use title for the current English typography.')
  static TextStyle get brand => title;

  @Deprecated('Use heading for the current English typography.')
  static TextStyle get section => heading;

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

