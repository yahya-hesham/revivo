import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/functions/extensions.dart';
import '../../../../core/functions/navigations.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/widgets/main_button.dart';
import '../widgets/auth_brand_footer.dart';
import '../widgets/auth_info_card.dart';

/// Session expired screen matching Figma `Session expired` (`3:151`).
class SessionExpiredScreen extends StatelessWidget {
  const SessionExpiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppConstants.paddingScreen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'auth.session_expired_title'.tr(),
                style: textTheme.headlineLarge?.copyWith(
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: AppConstants.space16),
              Text(
                'auth.session_expired_subtitle'.tr(),
                style: textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 80),
              AuthInfoCard(
                title: 'auth.session_expired_card_title'.tr(),
                subtitle: 'auth.session_expired_card_body'.tr(),
              ),
              const SizedBox(height: AppConstants.space16),
              MainButton(
                label: 'auth.sign_in'.tr(),
                onPressed: () => pushToBase(context, Routes.login),
              ),
              const SizedBox(height: AppConstants.space16),
              const AuthBrandFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
