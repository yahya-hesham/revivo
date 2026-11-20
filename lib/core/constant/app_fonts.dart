import 'package:google_fonts/google_fonts.dart';

abstract final class AppFonts {
  static String? get manrope => GoogleFonts.manrope().fontFamily;

  @Deprecated('Use manrope for the current English typography.')
  static String? get geist => GoogleFonts.geist().fontFamily;
  static String? get notoSansArabic => GoogleFonts.notoSansArabic().fontFamily;
}
