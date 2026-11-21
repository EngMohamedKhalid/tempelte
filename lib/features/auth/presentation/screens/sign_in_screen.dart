import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constant/app_assets.dart';
import '../../../../../core/shared/widgets/custom_button.dart';
import '../../../../../core/shared/widgets/custom_field_phone.dart';
import '../../../../../core/shared/widgets/custom_field_text.dart';
import '../../../../../core/style/app_colors.dart';
import '../../../../../core/style/app_size.dart';
import '../../../../../core/style/app_tokens.dart';
import '../../../../../core/validators/app_validators.dart';
import '../controller/auth_cubit.dart';
import '../widgets/auth_link_row.dart';
import '../widgets/auth_scaffold.dart';

/// Phone and password sign-in.
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(),
      child: BlocBuilder<AuthCubit, AuthState>(
        buildWhen: (previous, current) =>
            current is AuthLoading ||
            current is AuthGuestLoading ||
            current is AuthFailed ||
            current is AuthObscureChanged,
        builder: (context, state) {
          final AuthCubit cubit = AuthCubit.get(context);
          return AuthScaffold(
            showBack: false,
            title: 'sign_in.welcome'.tr(),
            subtitle: 'sign_in.login_hint'.tr(),
            child: Form(
              key: cubit.signInKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomFieldPhone(
                    title: 'sign_in.phone'.tr(),
                    controller: cubit.phoneController,
                    onPhoneChanged: cubit.onPhoneChanged,
                    onCountryChanged: cubit.onCountryChanged,
                  ),
                  SizedBox(height: AppSize.getHeight(AppSpacing.fieldGap)),
                  CustomFieldText(
                    title: 'sign_in.password'.tr(),
                    iconStart: AppIcons.lock,
                    controller: cubit.passwordController,
                    obscureText: cubit.obscurePassword,
                    validator: AppValidators.password,
                    iconEndTap: cubit.toggleObscurePassword,
                    iconEnd: cubit.obscurePassword
                        ? AppIcons.eyeClosed
                        : AppIcons.eyeOpen,
                  ),
                  SizedBox(height: AppSize.getHeight(8)),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: cubit.openForgetPassword,
                      child: Text('sign_in.forget'.tr()),
                    ),
                  ),
                  SizedBox(height: AppSize.getHeight(16)),
                  CustomButton(
                    // F26 round 3: the flow's main action is the green accent.
                    variant: ButtonVariant.accent,
                    onTap: cubit.signIn,
                    loading: state is AuthLoading,
                    title: 'sign_in.login_btn'.tr(),
                  ),
                  SizedBox(height: AppSize.getHeight(12)),
                  // Browse without an account. Deliberately quieter than the
                  // primary action: two full-width buttons stacked read as two
                  // equal choices, and this is not one.
                  Center(
                    child: TextButton(
                      onPressed: cubit.signInGuest,
                      child: state is AuthGuestLoading
                          ? SizedBox(
                              width: AppSize.getSize(16),
                              height: AppSize.getSize(16),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.typographyBody,
                              ),
                            )
                          : Text(
                              'onboarding.skip'.tr(),
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(color: AppColors.typographyBody),
                            ),
                    ),
                  ),
                  SizedBox(height: AppSize.getHeight(4)),
                  AuthLinkRow(
                    onTap: cubit.openSignUp,
                    action: 'sign_up.create_account'.tr(),
                    question: 'sign_up.no_account'.tr(),
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
