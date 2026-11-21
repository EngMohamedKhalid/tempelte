import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../constant/app_assets.dart';
import '../../style/app_colors.dart';
import '../../style/app_size.dart';
import 'custom_button.dart';
import 'custom_svg.dart';
import 'entrance.dart';

/// An error-state illustration with an optional reload control.
///
/// The legacy name is kept (D1); only its styling and entrance motion move
/// onto the design system in F19. The outer [InkWell] stays so existing tests
/// that tap the illustration keep working.
class CustomError extends StatelessWidget {
  /// Creates an error state. [onTap] retries and also shows a reload button
  /// when given.
  const CustomError({super.key, this.onTap, this.space});

  /// Space above the illustration; defaults to `125`.
  final double? space;

  /// Called to retry, from the illustration and from the reload button.
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Entrance(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              height: space ?? AppSize.getHeight(125),
            ),
            CustomSvg(svg: AppSvg.error, height: AppSize.getHeight(225)),
            SizedBox(height: AppSize.getHeight(30)),
            Text(
              'core.error_title'.tr(),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: AppColors.typographyHeading),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSize.getHeight(6)),
            Text(
              'core.error_desc'.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: AppColors.typographySubtitle),
            ),
            if (onTap != null) ...[
              SizedBox(height: AppSize.getHeight(16)),
              SizedBox(
                width: AppSize.getWidth(160),
                child: CustomButton(
                  title: 'core.reload'.tr(),
                  variant: ButtonVariant.secondary,
                  size: ButtonSize.sm,
                  leadingIcon: Icons.refresh_rounded,
                  onTap: onTap,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
