import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/shared/widgets/custom_button.dart';
import '../../../../../core/style/app_colors.dart';
import '../../../../../core/style/app_size.dart';
import '../controller/onboarding_cubit.dart';

/// The primary action, full width, with Skip sitting quietly beneath it.
///
/// The legacy row puts Skip and Next side by side separated by a fixed
/// 150px gap, which overflows on a small phone and lands on the wrong side in
/// Arabic. Stacking them makes the primary action unmissable and the secondary
/// one genuinely secondary.
class OnboardingControls extends StatelessWidget {
  const OnboardingControls({required this.cubit, super.key});

  final OnboardingCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomButton(
          onTap: cubit.nextTap,
          // Round 3: the flow's main action is the green accent.
          variant: ButtonVariant.accent,
          title: cubit.isLastPage
              ? 'onboarding.start'.tr()
              : 'onboarding.next'.tr(),
        ),
        SizedBox(height: AppSize.getHeight(4)),
        // Hidden on the last slide: Start and Skip would do the same thing,
        // and offering both invites a pointless decision.
        Opacity(
          opacity: cubit.isLastPage ? 0 : 1,
          child: IgnorePointer(
            ignoring: cubit.isLastPage,
            child: TextButton(
              onPressed: cubit.skip,
              child: Text(
                'onboarding.skip'.tr(),
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: AppColors.typographySubtitle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
