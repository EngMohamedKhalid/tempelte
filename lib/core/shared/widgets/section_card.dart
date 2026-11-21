import 'package:flutter/material.dart';

import '../../style/app_colors.dart';
import '../../style/app_shadow.dart';
import '../../style/app_size.dart';
import '../../style/app_tokens.dart';
import '../../style/app_tone.dart';
import 'icon_chip.dart';

/// A white card with an optional title and description above its content.
///
/// F26: an [icon] leads the title in a solid [IconChip] of [iconTone] (navy
/// when none), and [trailing] sits at the title row's end (a status badge, a
/// count).
class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.child,
    this.title,
    this.description,
    this.icon,
    this.iconTone,
    this.trailing,
    super.key,
  });

  final String? title;
  final String? description;
  final IconData? icon;
  final AppTone? iconTone;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppSize.getSize(AppRadius.card)),
        border: Border.all(color: AppColors.separatingPrimaryBorder),
        boxShadow: AppShadow.sm,
      ),
      child: Padding(
        padding: AppSize.padding(all: AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (title != null)
              Row(
                children: <Widget>[
                  if (icon != null) ...<Widget>[
                    IconChip(color: iconTone?.solidOn(dark: AppColors.isDark()) ?? AppColors.navy800, icon: icon!),
                    SizedBox(width: AppSize.getWidth(AppSpacing.gapS + 2)),
                  ],
                  Expanded(
                    child: Text(title!,
                        style: text.titleMedium!.copyWith(color: AppColors.typographyHeading)),
                  ),
                  ?trailing,
                ],
              ),
            if (description != null) ...<Widget>[
              SizedBox(height: AppSize.getHeight(4)),
              Text(description!,
                  style: text.bodyMedium!.copyWith(color: AppColors.typographySubtitle)),
            ],
            if (title != null || description != null)
              SizedBox(height: AppSize.getHeight(16)),
            child,
          ],
        ),
      ),
    );
  }
}
