import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/functions/extensions.dart';
import '../../../../core/styles/colors.dart';

/// Surface card matching Figma `Notification card` (`3:36`) and `Empty state` (`3:45`).
class AuthInfoCard extends StatelessWidget {
  const AuthInfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.isError = false,
  });

  final String title;
  final String subtitle;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Container(
      width: double.infinity,
      padding: AppConstants.paddingCard,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppConstants.borderRadius20,
        border: isError
            ? Border.all(color: AppColors.red.withValues(alpha: 0.35))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: context.textTheme.titleLarge?.copyWith(
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: AppConstants.space8),
          Text(
            subtitle,
            style: context.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
