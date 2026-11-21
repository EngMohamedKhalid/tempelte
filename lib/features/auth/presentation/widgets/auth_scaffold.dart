import 'package:flutter/material.dart';

import '../../../../../core/constant/app_assets.dart';
import '../../../../../core/helper/app_navigator.dart';
import '../../../../../core/shared/widgets/hero_background.dart';
import '../../../../../core/style/app_colors.dart';
import '../../../../../core/style/app_shadow.dart';
import '../../../../../core/style/app_size.dart';
import '../../../../../core/style/app_tokens.dart';

/// The shell every auth screen sits in.
///
/// F26 round 3, a new concept (owner: "change the flow design concept"): a
/// light page under a short navy hero; the logo in a white circle ringed in
/// green, straddling the hero's edge like a parking badge; the heading centred
/// below it; and the form in a white card. One shell means the five screens
/// cannot drift apart.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
    this.showBack = true,
  });

  /// Heading. Already translated.
  final String title;

  /// One line saying what to do here. Already translated.
  final String subtitle;

  /// The form.
  final Widget child;

  /// Whether to offer a way back.
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final double top = MediaQuery.paddingOf(context).top;
    final double badge = AppSize.getSize(112);
    final double heroHeight = top + AppSize.getHeight(150);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SingleChildScrollView(
        padding: EdgeInsetsDirectional.only(
          bottom: MediaQuery.paddingOf(context).bottom + AppSize.getHeight(AppSpacing.gapXl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The hero and the badge: the badge hangs half below the hero,
            // so the Stack reserves that half under it.
            SizedBox(
              height: heroHeight + badge / 2,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: heroHeight,
                    child: ClipRRect(
                      key: const Key('auth-hero'),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(AppSize.getSize(AppRadius.card * 2)),
                      ),
                      child: const HeroBackground(child: SizedBox.shrink()),
                    ),
                  ),
                  if (showBack)
                    PositionedDirectional(
                      top: top + AppSize.getHeight(AppSpacing.gapS),
                      start: AppSize.getWidth(AppSpacing.page),
                      child: Material(
                        color: AppColors.white.withValues(alpha: 0.14),
                        shape: const CircleBorder(),
                        child: IconButton(
                          key: const ValueKey<String>('auth_back'),
                          onPressed: AppNavigator.pop,
                          style: IconButton.styleFrom(
                            minimumSize: Size.square(AppSize.getSize(AppSpacing.minTouch)),
                          ),
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.white,
                            size: AppSize.getSize(24),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: heroHeight - badge / 2,
                    left: 0,
                    right: 0,
                    child: Center(
                      // The mark is navy and green, so it needs a light
                      // surface; tinting it would lose the green.
                      child: Container(
                        key: const Key('auth-logo'),
                        width: badge,
                        height: badge,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          // The badge's green ring — the concept's signature.
                          border: Border.all(color: AppColors.brand500, width: 4), // design: badge ring, not a card border
                          boxShadow: AppShadow.lg,
                        ),
                        child: Image.asset(
                          AppImages.logo,
                          width: AppSize.getWidth(68),
                          cacheWidth: AppSize.cacheWidth(AppSize.getWidth(68)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSize.getHeight(AppSpacing.gapL)),
            Padding(
              padding: AppSize.padding(horizontal: AppSpacing.page),
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: text.headlineSmall!.copyWith(
                      height: 1.2,
                      color: AppColors.typographyHeading,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: AppSize.getHeight(AppSpacing.gapS)),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: text.bodyMedium!.copyWith(
                      height: 1.5,
                      color: AppColors.typographySubtitle,
                    ),
                  ),
                  SizedBox(height: AppSize.getHeight(AppSpacing.gapXl)),
                  Container(
                    key: const Key('auth-form-card'),
                    width: double.infinity,
                    padding: AppSize.padding(all: AppSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(AppSize.getSize(AppRadius.card)),
                      border: Border.all(color: AppColors.separatingPrimaryBorder),
                      boxShadow: AppShadow.sm,
                    ),
                    child: child,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
