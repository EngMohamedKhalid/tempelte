import 'package:flutter/material.dart';

import '../../../../../core/shared/widgets/header_app_bar.dart';
import '../../../../../core/style/app_colors.dart';
import '../../../../../core/style/app_size.dart';

/// Stands in for a screen whose feature has not been built yet.
///
/// Every one is replaced when its feature lands. They exist so the entry flow
/// and its routing decisions are real and testable now, rather than written
/// blind and wired up later.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    required this.title,
    required this.feature,
    super.key,
  });

  /// The screen this stands in for.
  final String title;

  /// The feature that will replace it.
  final String feature;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderAppBar(title: title),
      body: Center(
        child: Padding(
          padding: AppSize.padding(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.construction_outlined,
                size: AppSize.getSize(48),
                color: AppColors.primary,
              ),
              SizedBox(height: AppSize.getHeight(16)),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: AppColors.typographyHeading,
                ),
              ),
              SizedBox(height: AppSize.getHeight(6)),
              Text(
                feature,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: AppColors.typographySubtitle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
