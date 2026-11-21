import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constant/app_assets.dart';
import '../../../../../core/helper/app_formatters.dart';
import '../../../../../core/shared/widgets/custom_button.dart';
import '../../../../../core/shared/widgets/custom_field_phone.dart';
import '../../../../../core/shared/widgets/custom_field_text.dart';
import '../../../../../core/style/app_size.dart';
import '../../../../../core/style/app_tokens.dart';
import '../../../../../core/validators/app_validators.dart';
import '../controller/auth_cubit.dart';
import '../widgets/auth_link_row.dart';
import '../widgets/auth_scaffold.dart';

/// Ordinary registration. The number is confirmed by OTP afterwards.
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(),
      child: BlocBuilder<AuthCubit, AuthState>(
        buildWhen: (previous, current) =>
            current is AuthLoading ||
            current is AuthFailed ||
            current is AuthObscureChanged,
        builder: (context, state) {
          final AuthCubit cubit = AuthCubit.get(context);
          return AuthScaffold(
            title: 'sign_up.create_account'.tr(),
            subtitle: 'sign_up.register_hint'.tr(),
            child: Form(
              key: cubit.signUpKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomFieldText(
                    title: 'sign_up.name'.tr(),
                    iconStart: AppIcons.user,
                    controller: cubit.nameController,
                    inputFormatters: [AppFormatters.names],
                    validator: AppValidators.required,
                  ),
                  SizedBox(height: AppSize.getHeight(AppSpacing.fieldGap)),
                  CustomFieldText(
                    title: 'sign_up.email'.tr(),
                    iconStart: AppIcons.email,
                    controller: cubit.emailController,
                    validator: AppValidators.email,
                    keyboardType: TextInputType.emailAddress,
                    inputFormatters: [AppFormatters.email],
                  ),
                  SizedBox(height: AppSize.getHeight(AppSpacing.fieldGap)),
                  CustomFieldPhone(
                    title: 'sign_up.phone'.tr(),
                    controller: cubit.phoneController,
                    onPhoneChanged: cubit.onPhoneChanged,
                    onCountryChanged: cubit.onCountryChanged,
                  ),
                  SizedBox(height: AppSize.getHeight(AppSpacing.fieldGap)),
                  CustomFieldText(
                    title: 'sign_up.password'.tr(),
                    iconStart: AppIcons.lock,
                    controller: cubit.passwordController,
                    obscureText: cubit.obscurePassword,
                    iconEndTap: cubit.toggleObscurePassword,
                    validator: (value) => AppValidators.minLength(value, 8),
                    iconEnd: cubit.obscurePassword
                        ? AppIcons.eyeClosed
                        : AppIcons.eyeOpen,
                  ),
                  SizedBox(height: AppSize.getHeight(AppSpacing.fieldGap)),
                  CustomFieldText(
                    title: 'sign_up.re_password'.tr(),
                    iconStart: AppIcons.lock,
                    controller: cubit.confirmController,
                    obscureText: cubit.obscureConfirm,
                    iconEndTap: cubit.toggleObscureConfirm,
                    validator: (value) => AppValidators.passwordIdentical(
                      value,
                      cubit.passwordController.text,
                    ),
                    iconEnd: cubit.obscureConfirm
                        ? AppIcons.eyeClosed
                        : AppIcons.eyeOpen,
                  ),
                  SizedBox(height: AppSize.getHeight(24)),
                  CustomButton(
                    // F26 round 3: the flow's main action is the green accent.
                    variant: ButtonVariant.accent,
                    onTap: cubit.signUp,
                    loading: state is AuthLoading,
                    title: 'sign_up.register'.tr(),
                  ),
                  SizedBox(height: AppSize.getHeight(12)),
                  AuthLinkRow(
                    onTap: cubit.openSignIn,
                    action: 'sign_up.login'.tr(),
                    question: 'sign_up.have_account'.tr(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
