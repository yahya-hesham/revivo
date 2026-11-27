import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/functions/extensions.dart';

/// Branded footer shown at the bottom of every onboarding & auth screen
/// (`REVIVO  /  KEEP YOUR CAR’S STORY`).
class AuthBrandFooter extends StatelessWidget {
  const AuthBrandFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'auth.brand_footer'.tr(),
      style: context.textTheme.bodySmall?.copyWith(
        color: context.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
