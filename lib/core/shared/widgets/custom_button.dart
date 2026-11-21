import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../style/app_colors.dart';
import '../../style/app_size.dart';
import '../../style/app_tokens.dart';
import 'custom_icon.dart';

/// What a button is for. One `primary` per screen — the thing to do.
enum ButtonVariant {
  /// Navy fill, white text. The screen's main action.
  primary,

  /// White fill, navy-200 border, navy-800 text.
  secondary,

  /// No fill, navy-700 text. Utilities: cancel, reset.
  ghost,

  /// Green fill, navy-950 text, both themes (F26): the main action inside a
  /// card or list row — Book now, Mark as ready, Accept. A screen's main
  /// bottom or form action stays [primary].
  accent,

  /// Red fill, white text. Always behind a confirmation.
  danger,
}

/// Button size. `sm` is visually smaller but keeps a 44+ touch target.
enum ButtonSize { md, sm }

/// The colours a button resolves to, idle and pressed.
@immutable
class ButtonColors {
  const ButtonColors({
    required this.bg,
    required this.fg,
    required this.pressedBg,
    this.border,
    this.pressedBorder,
  });

  final Color bg;
  final Color fg;
  final Color pressedBg;
  final Color? border;
  final Color? pressedBorder;
}

/// The app's button — the legacy name, restyled to the design system (F19).
///
/// Existing callers compile unchanged and become `primary`. [bgColor],
/// [textColor] and [borderColor] still override the variant for
/// compatibility; migrated screens name a [variant] instead.
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.icon,
    this.onTap,
    this.width,
    this.height,
    this.borderRadius,
    this.maxLines,
    this.bgColor,
    this.textColor,
    this.iconSize,
    this.iconColored,
    this.textSize,
    this.borderColor,
    required this.title,
    this.loading = false,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.onDark = false,
    this.leadingIcon,
  });

  final String title;
  final bool loading;

  /// A legacy asset icon (svg/png path), drawn through [CustomIcon].
  final String? icon;

  /// A Material icon shown before the label.
  final IconData? leadingIcon;
  final double? width;
  final int? maxLines;
  final double? height;
  final double? iconSize;
  final double? textSize;
  final Color? bgColor;
  final Color? textColor;
  final bool? iconColored;
  final Function()? onTap;
  final Color? borderColor;
  final BorderRadiusGeometry? borderRadius;
  final ButtonVariant variant;
  final ButtonSize size;

  /// Over a navy hero: the green CTA with navy-950 text.
  final bool onDark;

  /// The spec's colours for [variant], in the current theme.
  static ButtonColors colorsFor(
    ButtonVariant variant, {
    bool onDark = false,
    bool? dark,
  }) {
    final bool isDark = dark ?? AppColors.isDark();
    if (onDark && variant == ButtonVariant.primary) {
      return const ButtonColors(
        bg: AppColors.brand500,
        fg: AppColors.navy950,
        pressedBg: AppColors.brand400,
      );
    }
    switch (variant) {
      case ButtonVariant.primary:
        return isDark
            ? const ButtonColors(
                bg: AppColors.brand500,
                fg: AppColors.navy950,
                pressedBg: AppColors.brand400,
              )
            : const ButtonColors(
                bg: AppColors.navy800,
                fg: AppColors.white,
                pressedBg: AppColors.navy900,
              );
      case ButtonVariant.secondary:
        return isDark
            ? const ButtonColors(
                bg: AppColors.navy900,
                fg: AppColors.navy50,
                pressedBg: AppColors.navy800,
                border: AppColors.navy700,
                pressedBorder: AppColors.navy600,
              )
            : const ButtonColors(
                bg: AppColors.white,
                fg: AppColors.navy800,
                pressedBg: AppColors.navy50,
                border: AppColors.navy200,
                pressedBorder: AppColors.navy300,
              );
      case ButtonVariant.ghost:
        return isDark
            ? const ButtonColors(
                bg: Colors.transparent,
                fg: AppColors.navy100,
                pressedBg: AppColors.navy800,
              )
            : const ButtonColors(
                bg: Colors.transparent,
                fg: AppColors.navy700,
                pressedBg: AppColors.navy100,
              );
      case ButtonVariant.accent:
        return const ButtonColors(
          bg: AppColors.brand500,
          fg: AppColors.navy950,
          pressedBg: AppColors.brand400,
        );
      case ButtonVariant.danger:
        return const ButtonColors(
          bg: AppColors.danger,
          fg: AppColors.white,
          pressedBg: AppColors.dangerPressed,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ButtonColors c = colorsFor(variant, onDark: onDark);
    final Color bg = bgColor ?? c.bg;
    final Color fg = textColor ?? c.fg;
    final Color? border = borderColor ?? c.border;
    final bool small = size == ButtonSize.sm;
    final bool enabled = onTap != null;
    final double iconPx = AppSize.getSize(iconSize ?? 16);

    final Widget label = loading
        ? SizedBox(
            width: AppSize.getSize(18),
            height: AppSize.getSize(18),
            child: CircularProgressIndicator(strokeWidth: 2.5, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                CustomIcon(
                  icon: icon!,
                  width: iconPx,
                  height: iconPx,
                  withColor: iconColored ?? false,
                  color: fg,
                ),
                SizedBox(width: AppSize.getWidth(8)),
              ] else if (leadingIcon != null) ...<Widget>[
                Icon(leadingIcon, size: iconPx, color: fg),
                SizedBox(width: AppSize.getWidth(8)),
              ],
              Flexible(
                child: Text(
                  title,
                  maxLines: maxLines ?? 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: fg,
                    fontSize: AppSize.font(textSize ?? (small ? 12 : 14)),
                  ),
                ),
              ),
            ],
          );

    final Widget button = TextButton(
      onPressed: loading || !enabled ? null : onTap,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> s) =>
              s.contains(WidgetState.pressed) && bgColor == null ? c.pressedBg : bg,
        ),
        foregroundColor: WidgetStatePropertyAll<Color>(fg),
        overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
        side: border == null
            ? null
            : WidgetStateProperty.resolveWith(
                (Set<WidgetState> s) => BorderSide(
                  color: s.contains(WidgetState.pressed) && borderColor == null
                      ? (c.pressedBorder ?? border)
                      : border,
                ),
              ),
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: borderRadius ??
                BorderRadius.circular(AppSize.getSize(AppRadius.control)),
          ),
        ),
        padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
          AppSize.padding(horizontal: small ? 12 : 16, vertical: small ? 6 : 10),
        ),
        minimumSize: WidgetStatePropertyAll<Size>(
          // sm leaves its width floor at 0: `tapTargetSize: padded` already
          // pads an unconstrained sm button to kMinInteractiveDimension
          // (48×48) on both axes, so the 44pt floor holds without it too.
          Size(small ? 0 : AppSpacing.minTouch, small ? 32 : AppSpacing.minTouch),
        ),
        tapTargetSize: MaterialTapTargetSize.padded,
        animationDuration: AppMotion.color,
      ),
      child: label,
    );

    // The spec's 44pt floor applies on either axis, same as the default
    // height below: a `width:` caller (present or future) asking for less
    // than that on the non-`sm` size still gets `AppSpacing.minTouch`,
    // mirroring how `minimumSize` and `tapTargetSize: padded` already
    // protect the control from the inside; `sm` is left to those two alone
    // (see the comment by `minimumSize` above).
    final double resolvedWidth = small
        ? (width ?? double.infinity)
        : (width == null ? double.infinity : math.max(width!, AppSpacing.minTouch));

    return Opacity(
      opacity: enabled || loading ? 1 : 0.5,
      child: SizedBox(
        width: resolvedWidth,
        // `math.max` against [AppSpacing.minTouch]: `AppSize.getHeight(48)`
        // scales with the viewport, and an unusually short one (a real small
        // device, or a test surface AppSize cannot see because it falls back
        // to the platform's default view before the first frame) must never
        // pull the touch target itself below the 44pt floor `minimumSize`
        // and `tapTargetSize: padded` are meant to guarantee below.
        height: small
            ? null
            : (height ?? math.max(AppSize.getHeight(48), AppSpacing.minTouch)),
        child: button,
      ),
    );
  }
}
