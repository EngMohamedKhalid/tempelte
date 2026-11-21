import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../../core/constant/app_assets.dart';
import '../../../../../core/shared/widgets/custom_icon.dart';
import '../../../../../core/style/app_colors.dart';
import '../../../../../core/style/app_size.dart';
import '../../../../../core/style/app_tokens.dart';

/// The number a code was sent to, shown where it can be checked at a glance.
///
/// Buried in a sentence it is easy to skim past, and a typo in the number is
/// the commonest reason a code never arrives. Forced left-to-right: a phone
/// number is not language, and mirroring it makes it wrong.
class PhoneChip extends StatelessWidget {
  const PhoneChip({required this.phone, super.key});

  final String phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSize.padding(
        horizontal: AppSpacing.controlPaddingH,
        vertical: AppSpacing.controlPaddingV,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        border: Border.all(color: AppColors.separatingPrimaryBorder),
        borderRadius: BorderRadius.circular(AppSize.getSize(AppRadius.small)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIcon(
            width: 18,
            height: 18,
            icon: AppIcons.phone,
            color: AppColors.primary,
          ),
          SizedBox(width: AppSize.getWidth(AppSpacing.gapS)),
          Flexible(
            child: Directionality(
              textDirection: ui.TextDirection.ltr,
              child: Text(
                phone,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: AppColors.typographyHeading,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
