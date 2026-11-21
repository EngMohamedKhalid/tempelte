import 'package:flutter/material.dart';

import '../../style/app_colors.dart';
import '../../style/app_size.dart';
import '../../style/app_tokens.dart';
import '../../style/app_tone.dart';

/// A small labelled value on a tinted tile (F26): a card's key, car park,
/// payment. With a [tone] the tile takes that tone's tint and text — owed in
/// amber, paid in green; without one it sits on the quiet navy-50 surface.
class InfoTile extends StatelessWidget {
  const InfoTile({
    required this.label,
    required this.value,
    this.tone,
    super.key,
  });

  final String label;
  final String value;
  final AppTone? tone;

  @override
  Widget build(BuildContext context) {
    final bool dark = AppColors.isDark();
    final TextTheme text = Theme.of(context).textTheme;
    final Color bg =
        tone?.bgOn(dark: dark) ?? (dark ? AppColors.navy900 : AppColors.navy50);
    final Color labelColour = tone?.fgOn(dark: dark) ?? AppColors.quietText;
    final Color valueColour =
        tone?.fgOn(dark: dark) ?? AppColors.typographyHeading;

    return Container(
      padding: AppSize.padding(
        horizontal: AppSpacing.gapS + 2,
        vertical: AppSpacing.gapS,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(
          AppSize.getSize(AppRadius.small + 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.bodySmall!.copyWith(color: labelColour),
          ),
          // Scales down rather than cut off — an amount owed must be read
          // whole (final review).
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              maxLines: 1,
              style: text.titleSmall!.copyWith(
                color: valueColour,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
