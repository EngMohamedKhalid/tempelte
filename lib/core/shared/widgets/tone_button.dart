import 'package:flutter/material.dart';

import '../../style/app_colors.dart';
import '../../style/app_shadow.dart';
import '../../style/app_size.dart';
import '../../style/app_tokens.dart';
import '../../style/app_tone.dart';

/// A coloured action button: a tone's solid fill, a white icon and a white
/// one-line label (F26, the staff card's actions).
///
/// [outline] is for the destructive actions (Reject, Cancel reservation):
/// white, outlined and labelled in the tone, so it never reads as a safe tap.
/// A label longer than the button ends in an ellipsis rather than wrapping —
/// the owner asked for one line, and Urdu and Bengali run long.
class ToneButton extends StatelessWidget {
  const ToneButton({
    required this.tone,
    required this.icon,
    required this.label,
    this.onTap,
    this.loading = false,
    this.outline = false,
    super.key,
  });

  final AppTone tone;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  /// Shows a spinner in place of the icon and ignores taps.
  final bool loading;

  final bool outline;

  @override
  Widget build(BuildContext context) {
    final Color fg = outline ? tone.fg : AppColors.white;
    final BorderRadius radius = BorderRadius.circular(
      AppSize.getSize(AppRadius.control),
    );
    final double iconPx = AppSize.getSize(18);

    return Material(
      type: MaterialType.transparency,
      child: Ink(
        height: AppSize.getHeight(46),
        decoration: BoxDecoration(
          color: outline ? AppColors.white : tone.solidOn(dark: AppColors.isDark()),
          borderRadius: radius,
          // design: the destructive actions' outline is the tone's own solid,
          // not the card border — it is what tells them apart from the rest.
          border: outline ? Border.all(color: tone.solidOn(dark: AppColors.isDark()), width: 1.5) : null,
          boxShadow: outline ? null : AppShadow.sm,
        ),
        child: InkWell(
          onTap: loading ? null : onTap,
          borderRadius: radius,
          child: Padding(
            padding: AppSize.padding(horizontal: AppSpacing.gapS),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading)
                  RepaintBoundary(
                    child: SizedBox(
                      width: iconPx,
                      height: iconPx,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: fg,
                      ),
                    ),
                  )
                else
                  Icon(icon, size: iconPx, color: fg),
                SizedBox(width: AppSize.getWidth(AppSpacing.gapS)),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w800,
                      fontSize: AppSize.font(13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
