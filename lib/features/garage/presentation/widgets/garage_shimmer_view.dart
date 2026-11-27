import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/shimmer/app_shimmer.dart';

/// Skeleton loading view matching Figma `Loading garage` (`10:1209`).
class GarageShimmerView extends StatelessWidget {
  const GarageShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppConstants.paddingScreen,
      children: const [
        AppShimmerBox(width: 180, height: 32, borderRadius: AppConstants.borderRadius12),
        SizedBox(height: AppConstants.space12),
        AppShimmerBox(width: 240, height: 20, borderRadius: AppConstants.borderRadius12),
        SizedBox(height: AppConstants.space24),
        AppShimmerBox(height: 192),
        SizedBox(height: AppConstants.space16),
        AppShimmerBox(height: 92),
        SizedBox(height: AppConstants.space16),
        AppShimmerBox(height: 92),
      ],
    );
  }
}
