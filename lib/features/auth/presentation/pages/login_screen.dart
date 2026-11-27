import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/functions/extensions.dart';
import '../../../../core/functions/navigations.dart';
import '../../../../core/functions/validations.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../../../../core/widgets/main_button.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_brand_footer.dart';
import '../widgets/auth_info_card.dart';

/// Login screen matching Figma `Login` (`3:112`) and `Authentication error` (`3:131`).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().login(
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
            if (state is AuthLoginSuccess) {
              pushToBase(context, Routes.dashboard);
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            final errorState = state is AuthError ? state : null;
            final hasError = errorState != null;
            final credentialsError = errorState?.fieldError('credentials');

            return SingleChildScrollView(
              padding: AppConstants.paddingScreen,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasError
                          ? 'auth.login_error_heading'.tr()
                          : 'auth.login_title'.tr(),
                      style: textTheme.headlineLarge?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppConstants.space16),
                    Text(
                      hasError
                          ? 'auth.login_error_subheading'.tr()
                          : 'auth.login_subtitle'.tr(),
                      style: textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    if (hasError) ...[
                      const SizedBox(height: AppConstants.space16),
                      AuthInfoCard(
                        title: errorState.isNetworkError
                            ? 'auth.network_error_title'.tr()
                            : 'auth.login_error_card_title'.tr(),
                        subtitle: errorState.isCredentialsError
                            ? 'auth.login_error_card_body'.tr()
                            : (credentialsError ?? errorState.message),
                        isError: true,
                      ),
                    ] else
                      const SizedBox(height: AppConstants.space32),
                    const SizedBox(height: AppConstants.space16),
                    CustomTextFormField(
                      label: 'auth.email_label'.tr(),
                      hintText: 'auth.email_hint'.tr(),
                      controller: _emailController,
                      enabled: !isLoading,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      errorText: errorState?.fieldError('email'),
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
                      autofillHints: const [AutofillHints.password],
                      errorText: errorState?.fieldError('password'),
                      validator: AppValidations.loginPassword,
                      onChanged: (_) => context.read<AuthCubit>().clearError(),
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: AppConstants.space16),
                    MainButton(
                      label: hasError
                          ? 'auth.try_signing_in'.tr()
                          : 'auth.sign_in'.tr(),
                      isLoading: isLoading,
                      onPressed: _submit,
                    ),
                    if (!hasError) ...[
                      const SizedBox(height: AppConstants.space16),
                      Text(
                        'auth.session_note'.tr(),
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppConstants.space16),
                    MainButton(
                      label: hasError
                          ? 'auth.back_to_welcome'.tr()
                          : 'auth.create_account_cta'.tr(),
                      variant: MainButtonVariant.secondary,
                      onPressed: isLoading
                          ? null
                          : () {
                              if (hasError) {
                                pushToBase(context, Routes.welcome);
                              } else {
                                pushReplacement(context, Routes.register);
                              }
                            },
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
