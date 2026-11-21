import 'package:flutter/material.dart';

import '../../../../../core/shared/widgets/custom_svg.dart';
import '../../../../../core/style/app_colors.dart';
import '../../../../../core/style/app_size.dart';
import '../../data/models/onboarding_model.dart';

/// The illustration half of a slide, on the navy ground.
class OnboardingArtwork extends StatelessWidget {
  const OnboardingArtwork({required this.onboarding, super.key});

  final OnboardingModel onboarding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSize.padding(horizontal: 32, vertical: 16),
      child: CustomSvg(
        svg: onboarding.image,
        width: double.infinity,
        height: AppSize.getHeight(240),
      ),
    );
  }
}

/// The text half of a slide, on the light ground.
///
/// Start-aligned rather than centred: it reads the same way in Arabic and
/// English, and it gives the eye a single edge to return to instead of a
/// ragged centre.
class OnboardingCopy extends StatelessWidget {
  const OnboardingCopy({required this.onboarding, super.key});

  final OnboardingModel onboarding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          onboarding.title,
          maxLines: 2,
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
          // design: hero heading — 28/700, no textTheme role at this size
          style: TextStyle(
            height: 1.25,
            fontSize: AppSize.font(28),
            fontWeight: FontWeight.w700,
            color: AppColors.typographyHeading,
          ),
        ),
        SizedBox(height: AppSize.getHeight(12)),
        Text(
          onboarding.desc,
          maxLines: 4,
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            height: 1.6,
            color: AppColors.typographySubtitle,
          ),
        ),
      ],
    );
  }
}
