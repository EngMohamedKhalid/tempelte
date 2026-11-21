import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../../core/style/app_colors.dart';
import '../../../../../core/style/app_size.dart';
import '../../../../../core/style/app_tokens.dart';
import '../../../../../core/style/app_tone.dart';

/// "1 / 3" on a navy pill — which slide this is (F26 round 3). Numbers only,
/// read left to right in every language.
class OnboardingCounter extends StatelessWidget {
  const OnboardingCounter({required this.index, required this.count, super.key});

  /// Zero-based.
  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final bool dark = AppColors.isDark();
    return Container(
      padding: AppSize.padding(horizontal: AppSpacing.gapM, vertical: AppSpacing.gapXs),
      decoration: BoxDecoration(
        color: AppTone.navy.bgOn(dark: dark),
        borderRadius: BorderRadius.circular(AppSize.getSize(AppRadius.pill)),
      ),
      child: Text(
        '${index + 1} / $count',
        textDirection: ui.TextDirection.ltr,
        style: Theme.of(context).textTheme.labelMedium!.copyWith(
          color: AppTone.navy.fgOn(dark: dark),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
