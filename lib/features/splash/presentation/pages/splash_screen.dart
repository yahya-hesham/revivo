import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/functions/extensions.dart';
import '../../../../core/functions/navigations.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/styles/colors.dart';
import '../cubit/splash_cubit.dart';
import '../cubit/splash_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.94,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.teal,
        body: BlocConsumer<SplashCubit, SplashState>(
          listener: (context, state) {
            if (!context.mounted) return;
            if (state is SplashAuthenticated) {
              pushToBase(context, Routes.dashboard);
            } else if (state is SplashUnauthenticated) {
              pushToBase(context, Routes.welcome);
            } else if (state is SplashSessionExpired) {
              pushToBase(context, Routes.sessionExpired);
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: Padding(
                padding: AppConstants.paddingScreen,
                child: Stack(
                  children: [
                    Center(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'app_name'.tr(),
                                    style: context.textTheme.displayLarge
                                        ?.copyWith(
                                          color: AppColors.onBrand,
                                          letterSpacing: context.isArabic
                                              ? 0
                                              : -0.5,
                                        ),
                                  ),
                                  const SizedBox(width: AppConstants.space4),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Container(
                                      width: AppConstants.space8,
                                      height: AppConstants.space8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.accent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppConstants.space12),
                              Text(
                                'splash.tagline'.tr(),
                                textAlign: TextAlign.center,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.onBrand.withValues(
                                    alpha: 0.76,
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppConstants.space24,
                        ),
                        child: _buildFooter(context, state),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, SplashState state) {
    if (state is SplashError) {
      return Container(
        width: double.infinity,
        padding: AppConstants.paddingAll16,
        decoration: BoxDecoration(
          color: AppColors.pressed,
          borderRadius: AppConstants.borderRadius20,
          border: Border.all(color: AppColors.onBrand.withValues(alpha: 0.14)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'splash.connection_error'.tr(),
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.onBrand.withValues(alpha: 0.9),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.space12),
            ElevatedButton(
              onPressed: () => context.read<SplashCubit>().checkSession(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.ink,
                minimumSize: const Size(84, AppConstants.touchTargetSize),
                padding: AppConstants.paddingH16,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppConstants.borderRadius28,
                ),
              ),
              child: Text('common.retry'.tr()),
            ),
          ],
        ),
      );
    }

    if (state is SplashLoading && state.isCheckingRemote) {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
