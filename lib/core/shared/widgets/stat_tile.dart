import 'package:flutter/material.dart';

import '../../style/app_colors.dart';
import '../../style/app_shadow.dart';
import '../../style/app_size.dart';
import '../../style/app_tokens.dart';
import '../../style/app_tone.dart';

/// A counter: a label, an optional tone dot, and the screen's big figure.
class StatTile extends StatelessWidget {
  const StatTile({
    required this.label,
    required this.value,
    this.tone,
    this.selected = false,
    this.onTap,
    super.key,
  });

  final String label;
  final String value;

  /// Colours the dot beside [label]. No dot when null.
  final AppTone? tone;

  /// Green border and ring — for tiles that filter what is below them.
  final bool selected;

  /// Makes the tile tappable. Without it the tile is only a readout.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final BorderRadius radius = BorderRadius.circular(AppSize.getSize(AppRadius.card));

    final Widget box = AnimatedContainer(
      duration: AppMotion.of(context, AppMotion.color),
      curve: AppMotion.curve,
      child: DecoratedBox(
        key: const ValueKey<String>('stat_tile_box'),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: radius,
          // Controller ruling: selected/unselected borders are brand500 /
          // separatingPrimaryBorder at the default width — the glow below is
          // this tile's own non-colour cue for the selected state.
          border: Border.all(
            color: selected ? AppColors.brand500 : AppColors.separatingPrimaryBorder,
          ),
          boxShadow: selected
              ? <BoxShadow>[
                  BoxShadow(
                    color: AppColors.brand500.withValues(alpha: 0.3),
                    spreadRadius: 2,
                  ),
                ]
              : AppShadow.sm,
        ),
        child: Padding(
          padding: AppSize.padding(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  if (tone != null) ...<Widget>[
                    DecoratedBox(
                      key: const ValueKey<String>('stat_tile_dot'),
                      decoration: BoxDecoration(color: tone!.dot, shape: BoxShape.circle),
                      child: SizedBox.square(dimension: AppSize.getSize(8)),
                    ),
                    SizedBox(width: AppSize.getWidth(6)),
                  ],
                  // Scales down rather than cutting off, like the figure
                  // below: three tiles in one row leave "Completed" no room
                  // at full size in English (F24).
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        label,
                        maxLines: 1,
                        style: text.labelMedium!.copyWith(color: AppColors.typographySubtitle),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSize.getHeight(4)),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  value,
                  textDirection: TextDirection.ltr,
                  style: text.displaySmall!.copyWith(color: AppColors.typographyHeading),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (onTap == null) return box;
    return InkWell(onTap: onTap, borderRadius: radius, child: box);
  }
}
