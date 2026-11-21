import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/shared/widgets/custom_button.dart';
import '../../../../../core/shared/widgets/custom_field_phone.dart';
import '../../../../../core/style/app_size.dart';
import '../../../../../core/style/app_tokens.dart';
import '../controller/auth_cubit.dart';
import '../widgets/auth_scaffold.dart';

/// Starts password recovery.
class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(),
      child: BlocBuilder<AuthCubit, AuthState>(
        buildWhen: (previous, current) =>
            current is AuthLoading ||
            current is AuthFailed,
        builder: (context, state) {
          final AuthCubit cubit = AuthCubit.get(context);
          return AuthScaffold(
            title: 'recovery.forget.title'.tr(),
            subtitle: 'recovery.forget.desc'.tr(),
            child: Form(
              key: cubit.forgetKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomFieldPhone(
                    title: 'recovery.forget.phone'.tr(),
                    controller: cubit.phoneController,
                    onPhoneChanged: cubit.onPhoneChanged,
                    onCountryChanged: cubit.onCountryChanged,
                  ),
                  SizedBox(height: AppSize.getHeight(AppSpacing.gapXl)),
                  CustomButton(
                    // F26 round 3: the flow's main action is the green accent.
                    variant: ButtonVariant.accent,
                    onTap: cubit.sendResetCode,
                    loading: state is AuthLoading,
                    title: 'recovery.forget.send_code'.tr(),
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
