import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../functions/extensions.dart';

/// Surface info / empty-state card matching Figma `Empty state` (`3:45`).
class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Container(
      width: double.infinity,
      padding: AppConstants.paddingCard,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppConstants.borderRadius20,
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
