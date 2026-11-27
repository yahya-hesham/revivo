import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/functions/extensions.dart';
import '../../../../core/functions/navigations.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/widgets/main_button.dart';
import '../widgets/auth_brand_footer.dart';

/// Welcome screen matching Figma `03 — Onboarding & Authentication / Welcome` (`3:75`).
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
                'auth.welcome_title'.tr(),
                style: textTheme.headlineLarge?.copyWith(
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: AppConstants.space16),
              Text(
                'auth.welcome_subtitle'.tr(),
                style: textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppConstants.space16),
              ClipRRect(
                borderRadius: AppConstants.borderRadius20,
                child: SizedBox(
                  width: double.infinity,
                  height: 192,
                  child: Image.asset(
                    AppImages.welcomeVehicleHero,
                    fit: BoxFit.cover,
                    semanticLabel: 'auth.welcome_hero_caption'.tr(),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.space16),
              Text(
                'auth.welcome_hero_caption'.tr(),
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppConstants.space32),
              Text(
                'auth.welcome_section_title'.tr(),
                style: textTheme.titleLarge?.copyWith(
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: AppConstants.space16),
              Text(
                'auth.welcome_section_body'.tr(),
                style: textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppConstants.space16),
              MainButton(
                label: 'auth.create_account_cta'.tr(),
                onPressed: () => pushTo(context, Routes.register),
              ),
              const SizedBox(height: AppConstants.space16),
              MainButton(
                label: 'auth.already_have_account'.tr(),
                variant: MainButtonVariant.secondary,
                onPressed: () => pushTo(context, Routes.login),
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
