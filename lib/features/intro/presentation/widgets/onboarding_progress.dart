import 'package:flutter/material.dart';

import '../../../../../core/style/app_colors.dart';
import '../../../../../core/style/app_size.dart';
import '../../../../../core/style/app_tokens.dart';

/// Progress through the slides, drawn as painted bay segments.
///
/// Segments rather than dots because three slides are a genuine sequence with
/// a start and an end, and a filling bar says how far along you are — a row of
/// dots only says which one is active.
class OnboardingProgress extends StatelessWidget {
  const OnboardingProgress({
    required this.count,
    required this.index,
    super.key,
  });

  /// Total slides.
  final int count;

  /// Zero-based index of the slide showing.
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(count, (int i) {
        final bool filled = i <= index;
        return Expanded(
          child: Padding(
            padding: AppSize.padding(end: i == count - 1 ? 0 : 6),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              height: AppSize.getHeight(4),
              decoration: BoxDecoration(
                color: filled ? AppColors.secondary : AppColors.greyC8,
                // Any radius at least half the bar's height (4) renders the
                // same full stadium cap — AppRadius.pill, not a raw 2.
                borderRadius: BorderRadius.circular(
                  AppSize.getSize(AppRadius.pill),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
