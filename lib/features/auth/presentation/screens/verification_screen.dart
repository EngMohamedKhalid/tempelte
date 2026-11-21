import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/shared/widgets/custom_button.dart';
import '../../../../../core/shared/widgets/custom_field_otp.dart';
import '../../../../../core/style/app_size.dart';
import '../../../../../core/style/app_tokens.dart';
import '../../data/params/verify_otp_param.dart';
import '../controller/auth_cubit.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/otp_resend_row.dart';
import '../widgets/phone_chip.dart';

/// Confirms a phone number with the code sent to it.
class VerificationScreen extends StatelessWidget {
  const VerificationScreen({
    required this.phone,
    required this.purpose,
    super.key,
  });

  /// Full international number the code went to.
  final String phone;

  /// Registration or password recovery.
  final OtpPurpose purpose;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit()..startCountdown(),
      child: BlocBuilder<AuthCubit, AuthState>(
        // The resend countdown, and the verify button's spinner.
        buildWhen: (previous, current) =>
            current is AuthOtpTicked ||
            (previous is AuthLoading) != (current is AuthLoading),
        builder: (context, state) {
          final AuthCubit cubit = AuthCubit.get(context);
          return AuthScaffold(
            title: 'verification.title'.tr(),
            // The number lives in the chip below, where it can be checked at
            // a glance, so the subtitle does not repeat it.
            subtitle: 'verification.sent_to'.tr(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: PhoneChip(phone: phone),
                ),
                SizedBox(height: AppSize.getHeight(24)),
                CustomFieldOtp(
                  controller: cubit.codeController,
                  onComplete: () => cubit.verify(phoneNumber: phone, purpose: purpose),
                ),
                SizedBox(height: AppSize.getHeight(20)),
                OtpResendRow(
                  onResend: () => cubit.resend(phoneNumber: phone, purpose: purpose),
                  secondsLeft: cubit.secondsLeft,
                ),
                SizedBox(height: AppSize.getHeight(AppSpacing.gapXl)),
                CustomButton(
                    // F26 round 3: the flow's main action is the green accent.
                    variant: ButtonVariant.accent,
                  onTap: () => cubit.verify(phoneNumber: phone, purpose: purpose),
                  title: 'verification.confirm'.tr(),
                  loading: state is AuthLoading,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
