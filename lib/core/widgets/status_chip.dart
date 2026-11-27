import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../functions/extensions.dart';
import '../styles/colors.dart';

enum StatusChipType { onTrack, dueSoon, overdue, estimated, readOnly }

/// Status pill matching Figma `Status` (`3:32`).
/// Never relies on color alone — always pairs semantic tint with explicit label text.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.type,
  });

  final String label;
  final StatusChipType type;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (type) {
      StatusChipType.overdue => (AppColors.redSoft, AppColors.red),
      StatusChipType.dueSoon => (AppColors.amberSoft, AppColors.amber),
      StatusChipType.onTrack ||
      StatusChipType.estimated ||
      StatusChipType.readOnly =>
        (AppColors.successSoft, AppColors.success),
    };

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppConstants.space16,
        vertical: AppConstants.space8,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppConstants.borderRadius20,
      ),
      child: Text(
        label,
        style: context.textTheme.bodySmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
