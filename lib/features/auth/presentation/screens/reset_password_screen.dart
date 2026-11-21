import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constant/app_assets.dart';
import '../../../../../core/shared/widgets/custom_button.dart';
import '../../../../../core/shared/widgets/custom_field_text.dart';
import '../../../../../core/style/app_size.dart';
import '../../../../../core/style/app_tokens.dart';
import '../../../../../core/validators/app_validators.dart';
import '../controller/auth_cubit.dart';
import '../widgets/auth_scaffold.dart';

/// Sets a new password after the number has been proven.
class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({
    required this.phone,
    required this.verificationToken,
    super.key,
  });

  /// Full international number, used when the server issued no token.
  final String phone;

  /// Single-use token from OTP verification, when the server issued one.
  final String verificationToken;

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
            title: 'recovery.reset.title'.tr(),
            subtitle: 'recovery.reset.desc'.tr(),
            child: Form(
              key: cubit.resetKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomFieldText(
                    title: 'recovery.reset.new_password'.tr(),
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
                    title: 'recovery.reset.re_new_password'.tr(),
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
                  SizedBox(height: AppSize.getHeight(AppSpacing.gapXl)),
                  CustomButton(
                    // F26 round 3: the flow's main action is the green accent.
                    variant: ButtonVariant.accent,
                    onTap: () => cubit.resetPassword(
                      phoneNumber: phone,
                      verificationToken: verificationToken,
                    ),
                    loading: state is AuthLoading,
                    title: 'recovery.reset.reset_btn'.tr(),
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
