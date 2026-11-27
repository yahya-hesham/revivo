import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/functions/extensions.dart';
import '../../../../core/functions/navigations.dart';
import '../../../../core/functions/validations.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../../../../core/widgets/dialogs.dart';
import '../../../../core/widgets/main_button.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_brand_footer.dart';
import '../widgets/auth_info_card.dart';

/// Register screen matching Figma `03 — Onboarding & Authentication / Register` (`3:91`).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().register(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (!context.mounted) return;
            if (state is AuthRegisterSuccess) {
              showMyDialog(
                context,
                'auth.register_success'.tr(),
                type: DialogType.success,
              );
              pushReplacement(context, Routes.login, extra: state.email);
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            final errorState = state is AuthError ? state : null;
            final nameServerError = errorState?.fieldError('name');
            final emailServerError = errorState?.fieldError('email');
            final passwordServerError = errorState?.fieldError('password');
            final hasFieldErrors = nameServerError != null ||
                emailServerError != null ||
                passwordServerError != null;

            return SingleChildScrollView(
              padding: AppConstants.paddingScreen,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'auth.register_title'.tr(),
                      style: textTheme.headlineLarge?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppConstants.space16),
                    Text(
                      'auth.register_subtitle'.tr(),
                      style: textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    if (errorState != null && !hasFieldErrors) ...[
                      const SizedBox(height: AppConstants.space16),
                      AuthInfoCard(
                        title: errorState.isConflict
                            ? 'auth.email_exists_title'.tr()
                            : 'auth.register_error_title'.tr(),
                        subtitle: errorState.message,
                        isError: true,
                      ),
                    ],
                    const SizedBox(height: AppConstants.space16),
                    CustomTextFormField(
                      label: 'auth.name_label'.tr(),
                      hintText: 'auth.name_hint'.tr(),
                      controller: _nameController,
                      enabled: !isLoading,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      errorText: nameServerError,
                      validator: (v) => AppValidations.requiredText(
                        v,
                        fieldName: 'auth.name_label'.tr(),
                        maxLength: 100,
                      ),
                      onChanged: (_) => context.read<AuthCubit>().clearError(),
                    ),
                    const SizedBox(height: AppConstants.space16),
                    CustomTextFormField(
                      label: 'auth.email_label'.tr(),
                      hintText: 'auth.email_hint'.tr(),
                      controller: _emailController,
                      enabled: !isLoading,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      errorText: emailServerError,
                      validator: AppValidations.email,
                      onChanged: (_) => context.read<AuthCubit>().clearError(),
                    ),
                    const SizedBox(height: AppConstants.space16),
                    CustomTextFormField(
                      label: 'auth.password_label'.tr(),
                      hintText: 'auth.password_hint'.tr(),
                      controller: _passwordController,
                      enabled: !isLoading,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      errorText: passwordServerError,
                      validator: AppValidations.registerPassword,
                      onChanged: (_) => context.read<AuthCubit>().clearError(),
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: AppConstants.space16),
                    Text(
                      'auth.password_rules'.tr(),
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppConstants.space16),
                    MainButton(
                      label: 'auth.register_submit'.tr(),
                      isLoading: isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: AppConstants.space16),
                    MainButton(
                      label: 'auth.sign_in_instead'.tr(),
                      variant: MainButtonVariant.secondary,
                      onPressed: isLoading
                          ? null
                          : () => pushReplacement(context, Routes.login),
                    ),
                    const SizedBox(height: AppConstants.space16),
                    const AuthBrandFooter(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
