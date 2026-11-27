import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_constants.dart';
import '../styles/colors.dart';

/// Reusable skeleton shimmer block for loading states.
class AppShimmerBox extends StatelessWidget {
  const AppShimmerBox({
    super.key,
    this.width = double.infinity,
    this.height = 88,
    this.borderRadius = AppConstants.borderRadius20,
  });

  final double width;
  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.darkSurface : AppColors.soft;
    final highlightColor = isDark ? const Color(0xFF264043) : AppColors.surface;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}
