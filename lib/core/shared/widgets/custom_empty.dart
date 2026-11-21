import 'package:flutter/material.dart';

import '../../constant/app_assets.dart';
import '../../style/app_colors.dart';
import '../../style/app_size.dart';
import '../../style/app_tokens.dart';
import 'custom_svg.dart';
import 'entrance.dart';

/// An empty-state illustration with an optional title and description.
///
/// The legacy name is kept (D1); only its styling and entrance motion move
/// onto the design system in F19.
class CustomEmpty extends StatelessWidget {
  /// Creates an empty state. [text] defaults to a generic message.
  const CustomEmpty({
    super.key,
    this.svg,
    this.text,
    this.image,
    this.title,
    this.topSpace,
  });

  /// A legacy svg asset path; defaults to [AppIcons.empty2].
  final String? svg;

  /// The description shown under the title.
  final String? text;

  /// An optional heading above [text].
  final String? title;

  /// A raster illustration, used instead of [svg] when given.
  final String? image;

  /// Space above the illustration; defaults to `125`.
  final double? topSpace;

  @override
  Widget build(BuildContext context) {
    return Entrance(
      // The page inset: the default illustration is wider than a phone, and
      // without it the artwork ran to the screen's edge.
      child: Padding(
        padding: AppSize.padding(horizontal: AppSpacing.page),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: AppSize.getHeight(topSpace ?? 125),
            ),
            if (image != null)
              Image.asset(image!, height: AppSize.getHeight(260))
            else
              CustomSvg(
                svg: svg ?? AppIcons.empty2,
                height: AppSize.getHeight(260),
              ),
            if (title != null) ...[
              SizedBox(height: AppSize.getHeight(24)),
              Text(
                title!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium!
                    .copyWith(color: AppColors.typographyHeading),
              ),
            ],
            SizedBox(height: AppSize.getHeight(6)),
            Text(
              text ?? 'Nothing here!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium!
                  .copyWith(color: AppColors.typographySubtitle),
            ),
          ],
        ),
      ),
    );
  }
}
