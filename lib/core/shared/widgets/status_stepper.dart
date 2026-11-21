import 'package:flutter/material.dart';

import '../../style/app_colors.dart';
import '../../style/app_size.dart';
import '../../style/app_tokens.dart';
import '../../style/app_tone.dart';
import 'status_stepper_step.dart';

/// A booking's lifecycle as a stepper (F26, owner: "more clear", "same align").
///
/// Done steps are filled circles with a check, the [current] one a larger
/// ringed circle with a bold label and a [nowLabel] pill, later ones numbered
/// outlines. Every circle is centred in the same fixed-height row, so all the
/// labels share one line. `current == -1` (cancelled, unknown) shows no
/// progress at all. Each step keeps its text label: status is never colour
/// alone.
class StatusStepper extends StatelessWidget {
  const StatusStepper({
    required this.labels,
    required this.current,
    required this.nowLabel,
    this.tone = AppTone.sky,
    super.key,
  });

  final List<String> labels;
  final int current;
  final String nowLabel;
  final AppTone tone;

  @override
  Widget build(BuildContext context) {
    final bool dark = AppColors.isDark();
    return Container(
      padding: AppSize.padding(
        horizontal: AppSpacing.gapXs,
        top: 14,
        bottom: AppSpacing.gapM,
      ),
      decoration: BoxDecoration(
        color: dark ? AppColors.navy900 : AppColors.navy50,
        borderRadius: BorderRadius.circular(AppSize.getSize(14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int i = 0; i < labels.length; i++)
            Expanded(
              child: StatusStepperStep(
                label: labels[i],
                index: i,
                count: labels.length,
                current: current,
                nowLabel: nowLabel,
                tone: tone,
              ),
            ),
        ],
      ),
    );
  }
}
