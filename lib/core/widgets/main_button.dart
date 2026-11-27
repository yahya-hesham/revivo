import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../styles/colors.dart';

enum MainButtonVariant { primary, secondary, danger }

/// Standardized button matching Revivo Figma Button variants:
/// Primary, Secondary, Danger, Disabled, and Loading.
class MainButton extends StatelessWidget {
  const MainButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = MainButtonVariant.primary,
    this.isLoading = false,
    this.leading,
  });

  final String label;
  final VoidCallback? onPressed;
  final MainButtonVariant variant;
  final bool isLoading;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;
    final child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _foregroundColor(context),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppConstants.space8),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    if (variant == MainButtonVariant.secondary) {
      return OutlinedButton(
        onPressed: effectiveOnPressed,
        child: child,
      );
    }

    final style = variant == MainButtonVariant.danger
        ? ElevatedButton.styleFrom(
            backgroundColor: AppColors.redSoft,
            foregroundColor: AppColors.red,
          )
        : null;

    return ElevatedButton(
      onPressed: effectiveOnPressed,
      style: style,
      child: child,
    );
  }

  Color _foregroundColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return switch (variant) {
      MainButtonVariant.primary => scheme.onPrimary,
      MainButtonVariant.secondary => scheme.primary,
      MainButtonVariant.danger => AppColors.red,
    };
  }
}
