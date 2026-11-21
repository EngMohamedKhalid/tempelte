import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../style/app_colors.dart';
import '../../style/app_size.dart';
import '../../style/app_tokens.dart';

/// Which app a header belongs to: the customer's navy-800 or staff's
/// near-black navy-950, so the two apps are told apart at a glance.
enum HeaderTone { customer, staff }

/// The bold top band every F26 screen opens with: a solid navy fill (never a
/// gradient), an optional green eyebrow line, the title in white, a leading
/// control (back, avatar), trailing actions and an optional [bottom] (a search
/// field, the shift pill).
///
/// [extendBelow] adds room under the band's content for a card to overlap it
/// — see [HeaderOverlap], which must be given the same amount.
class HeaderBand extends StatelessWidget {
  const HeaderBand({
    required this.title,
    this.eyebrow,
    this.leading,
    this.icon,
    this.actions = const <Widget>[],
    this.bottom,
    this.tone = HeaderTone.customer,
    this.extendBelow = 0,
    this.compact = false,
    super.key,
  });

  final String title;
  final String? eyebrow;
  final Widget? leading;

  /// The screen's own glyph, on a green tile before the title (round 3).
  final IconData? icon;
  final List<Widget> actions;
  final Widget? bottom;
  final HeaderTone tone;

  /// Logical pixels added below the content, unscaled, so it matches the
  /// overlap exactly.
  final double extendBelow;

  /// In an app-bar slot (`HeaderAppBar`): one-line title, tighter bottom.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Color fill = tone == HeaderTone.staff
        ? AppColors.headerStaff
        : AppColors.headerCustomer;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      // Owner: rounded bottom corners, solid colour — never a gradient, and
      // (round 3) no decorative circles.
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(AppSize.getSize(AppRadius.card * 1.5)),
          ),
        ),
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: AppSize.getWidth(AppSpacing.page),
                end: AppSize.getWidth(AppSpacing.page),
                top: MediaQuery.paddingOf(context).top + AppSize.getHeight(AppSpacing.gapM),
                bottom: AppSize.getHeight(compact ? AppSpacing.gapM : AppSpacing.gapXl - AppSpacing.gapXs) + extendBelow,
              ),
              child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                if (leading != null) ...<Widget>[
                  leading!,
                  SizedBox(width: AppSize.getWidth(AppSpacing.gapM)),
                ],
                if (icon != null) ...<Widget>[
                  // F26 round 3: each screen's glyph on the green accent.
                  Container(
                    key: const Key('header-icon'),
                    width: AppSize.getSize(44),
                    height: AppSize.getSize(44),
                    decoration: BoxDecoration(
                      color: AppColors.brand500,
                      borderRadius: BorderRadius.circular(AppSize.getSize(AppRadius.control)),
                    ),
                    child: Icon(icon, size: AppSize.getSize(24), color: AppColors.navy950),
                  ),
                  SizedBox(width: AppSize.getWidth(AppSpacing.gapM)),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (eyebrow != null)
                        Text(
                          eyebrow!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodySmall!.copyWith(
                            color: AppColors.headerEyebrow,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      Text(
                        title,
                        maxLines: compact ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        // Round 3: an app bar's title is the large one.
                        style: (compact ? text.headlineSmall! : text.titleLarge!).copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                for (final Widget action in actions) ...<Widget>[
                  SizedBox(width: AppSize.getWidth(AppSpacing.gapS)),
                  action,
                ],
              ],
            ),
            if (bottom != null) ...<Widget>[
              SizedBox(height: AppSize.getHeight(AppSpacing.gapL)),
              bottom!,
            ],
          ],
        ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A square control on a header band: back, map, scan. [accent] makes it the
/// green call to action (the staff scan button).
class HeaderAction extends StatelessWidget {
  const HeaderAction({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
    this.accent = false,
    this.round = false,
    super.key,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;
  final bool accent;

  /// A circle rather than a rounded square — the back button (round 3).
  final bool round;

  @override
  Widget build(BuildContext context) {
    final double side = AppSize.getSize(44);
    final BorderRadius radius = BorderRadius.circular(
      AppSize.getSize(round ? AppRadius.pill : AppRadius.control),
    );
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: accent
            ? AppColors.brand500
            : round
            ? AppColors.white.withValues(alpha: 0.14)
            : AppColors.headerControl,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: SizedBox(
            width: side,
            height: side,
            child: Icon(
              icon,
              size: AppSize.getSize(22),
              color: accent ? AppColors.navy950 : AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
