import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../style/app_colors.dart';
import '../../style/app_size.dart';
import '../../validators/app_validators.dart';

/// The OTP entry field.
///
/// Migrated to pin_code_fields 10, which replaced `PinCodeTextField` with
/// `MaterialPinFormField` and swapped [TextEditingController] for its own
/// [PinInputController].
///
/// The controller is still created, held and disposed by the screen's cubit —
/// it is just a different type now. That is the same rule as every other
/// field, and it suits this widget better: `PinInputController` also owns the
/// focus node the legacy version had no way to reach.
///
/// Wrapped in an LTR [Directionality] because digits are entered left to right
/// even in Arabic and Urdu.
class CustomFieldOtp extends StatelessWidget {
  const CustomFieldOtp({
    super.key,
    required this.onComplete,
    required this.controller,
    this.length = 4,
    this.keyboardType = TextInputType.number,
  });

  /// Fired once every cell is filled.
  final VoidCallback onComplete;

  /// Owned by the cubit, never created here.
  final PinInputController controller;

  /// Number of cells.
  final int length;

  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    final double cell = AppSize.getSize(48);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: MaterialPinFormField(
        length: length,
        pinController: controller,
        keyboardType: keyboardType,
        validator: AppValidators.otp,
        onCompleted: (_) => onComplete(),
        autovalidateMode: AutovalidateMode.disabled,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        theme: MaterialPinTheme(
          borderWidth: 1,
          spacing: AppSize.getSize(8),
          cellSize: Size(cell, cell),
          shape: MaterialPinShape.outlined,
          borderRadius: BorderRadius.circular(AppSize.getSize(12)),
          borderColor: AppColors.inputOutline,
          focusedBorderColor: AppColors.primary,
          filledBorderColor: AppColors.primary,
          fillColor: AppColors.inputBackground,
          focusedFillColor: AppColors.inputBackground,
          filledFillColor: AppColors.inputBackground,
          cursorColor: AppColors.primary,
          // Dark-aware: #B91C1C is 2.7:1 on the dark field, under the 3:1 a
          // border needs.
          errorColor: AppColors.errorText,
        ),
      ),
    );
  }
}
