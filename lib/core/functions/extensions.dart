import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

extension RevivoContextExtensions on BuildContext {
  bool get isArabic => locale.languageCode == 'ar';
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
}
