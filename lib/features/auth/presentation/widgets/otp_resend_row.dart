import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/style/app_colors.dart';

/// The resend control, which becomes a countdown while it is unavailable.
///
/// One element that changes state rather than two that swap, so the row does
/// not jump. The countdown is shown because the endpoint is rate limited per
/// phone and per IP — telling someone to wait beats letting them tap into a
/// 429.
class OtpResendRow extends StatelessWidget {
  const OtpResendRow({
    required this.secondsLeft,
    required this.onResend,
    super.key,
  });

  final int secondsLeft;
  final VoidCallback onResend;

  bool get _canResend => secondsLeft <= 0;

  String get _clock {
    final int safe = secondsLeft < 0 ? 0 : secondsLeft;
    final String seconds = (safe % 60).toString().padLeft(2, '0');
    return '${safe ~/ 60}:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_canResend) {
      return TextButton(
        onPressed: onResend,
        child: Text(
          'verification.resend'.tr(),
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
            color: AppColors.primary,
          ),
        ),
      );
    }

    return Text(
      'verification.expired_at'.tr(namedArgs: <String, String>{'time': _clock}),
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: AppColors.typographySubtitle,
      ),
    );
  }
}
