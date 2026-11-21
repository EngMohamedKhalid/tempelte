import 'package:flutter/material.dart';

import '../../style/app_colors.dart';
import '../../style/app_size.dart';
import '../../style/app_tokens.dart';
import '../../style/app_tone.dart';

/// One column of a [StatusStepper]: the connector-and-circle row (a fixed
/// height, so every label lines up), the label, and the now pill on the
/// current step.
class StatusStepperStep extends StatelessWidget {
  const StatusStepperStep({
    required this.label,
    required this.index,
    required this.count,
    required this.current,
    required this.nowLabel,
    required this.tone,
    super.key,
  });

  final String label;
  final int index;
  final int count;
  final int current;
  final String nowLabel;
  final AppTone tone;

  @override
  Widget build(BuildContext context) {
    final bool dark = AppColors.isDark();
    final int i = index;
    final TextTheme text = Theme.of(context).textTheme;
    final bool done = current >= 0 && i < current;
    final bool now = i == current;
    // The solid step, so the white check clears 3:1 (final review).
    final Color reached = tone.solidOn(dark: dark);
    final Color pending = dark ? AppColors.navy700 : AppColors.navy200;
    Color line(int k) => current >= 0 && k <= current ? reached : pending;

    final double small = AppSize.getSize(24);
    final double big = AppSize.getSize(30);

    final Widget circle;
    if (done) {
      circle = Container(
        width: small,
        height: small,
        decoration: BoxDecoration(color: reached, shape: BoxShape.circle),
        child: Icon(
          Icons.check_rounded,
          size: AppSize.getSize(14),
          color: AppColors.white,
        ),
      );
    } else if (now) {
      circle = Container(
        width: big,
        height: big,
        decoration: BoxDecoration(
          color: tone.solidOn(dark: AppColors.isDark()),
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(color: tone.bgOn(dark: dark), spreadRadius: 4),
          ],
        ),
        alignment: Alignment.center,
        child: Container(
          width: AppSize.getSize(10),
          height: AppSize.getSize(10),
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
          ),
        ),
      );
    } else {
      circle = Container(
        width: small,
        height: small,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          shape: BoxShape.circle,
          // design: an upcoming step is an outline, not a filled tint.
          border: Border.all(color: pending, width: 2),
        ),
        child: Text(
          '${i + 1}',
          style: text.labelSmall!.copyWith(
            color: AppColors.quietText,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      );
    }

    final double stroke = AppSize.getHeight(3);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: big,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: stroke,
                  color: i == 0 ? Colors.transparent : line(i),
                ),
              ),
              circle,
              Expanded(
                child: Container(
                  height: stroke,
                  color: i == count - 1 ? Colors.transparent : line(i + 1),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSize.getHeight(6)),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: text.labelSmall!.copyWith(
            fontWeight: now ? FontWeight.w800 : FontWeight.w700,
            color: current < 0 || i > current
                ? AppColors.quietText
                : now
                ? AppColors.typographyHeading
                : tone.fgOn(dark: dark),
          ),
        ),
        if (now) ...<Widget>[
          SizedBox(height: AppSize.getHeight(AppSpacing.gapXs)),
          Container(
            padding: AppSize.padding(horizontal: AppSpacing.gapS),
            decoration: BoxDecoration(
              color: tone.solidOn(dark: AppColors.isDark()),
              borderRadius: BorderRadius.circular(
                AppSize.getSize(AppRadius.pill),
              ),
            ),
            child: Text(
              nowLabel,
              style: text.labelSmall!.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
