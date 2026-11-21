import 'package:flutter/widgets.dart';

/// Corner radii from the design system, in design units (scale with
/// `AppSize.getSize`).
abstract final class AppRadius {
  /// Inline chips inside inputs, icon buttons.
  static const double small = 8;

  /// Buttons, inputs, selects, dropdown lists, toasts.
  static const double control = 12;

  /// Cards, stat tiles, sections, dialogs.
  static const double card = 16;

  /// Badges, status pills, dots.
  static const double pill = 999;
}

/// The 4-point spacing grid and the named gaps built on it.
abstract final class AppSpacing {
  /// The fundamental spacing unit: 4 points.
  /// All spacing values sit on this grid.
  static const double grid = 4;

  /// Horizontal padding of every screen body and list — the page gutter.
  /// Not in design-tokens.json (the web uses Tailwind's scale); derived.
  static const double page = 16;

  /// Padding inside cards, tiles, sections and dialog bodies (CustomDialog keeps its own 24, the spec's dialog padding).
  static const double cardPadding = 20;

  /// Vertical spacing between form fields within a group.
  static const double fieldGap = 20;

  /// Vertical spacing between form field label and input.
  static const double labelGap = 6;

  /// Horizontal padding inside buttons and controls.
  static const double controlPaddingH = 14;

  /// Vertical padding inside buttons and controls.
  static const double controlPaddingV = 10;

  /// Minimum touch target on either axis.
  static const double minTouch = 44;

  /// The gap scale, on the 4-pt grid. Everything that is not a named gap
  /// above (card padding, field gap, label gap) uses one of these.
  /// 4 — hairline gaps: a badge from its text, stacked caption lines.
  static const double gapXs = 4;

  /// 8 — icon → text.
  static const double gapS = 8;

  /// 12 — between cards in a list.
  static const double gapM = 12;

  /// 16 — between groups inside a card or section.
  static const double gapL = 16;

  /// 24 — between sections on a screen.
  static const double gapXl = 24;

  /// 32 — large separations: a hero from the content below it.
  static const double gapXxl = 32;
}

/// Durations and the easing curve, plus the reduce-motion switch.
abstract final class AppMotion {
  /// Content entering: rise [enterOffsetY] and fade in.
  static const Duration enter = Duration(milliseconds: 800);

  /// Colour transitions (buttons, tiles).
  static const Duration color = Duration(milliseconds: 200);

  /// A status changing.
  static const Duration status = Duration(milliseconds: 400);

  /// How long a toast stays up.
  static const Duration toastDismiss = Duration(milliseconds: 5000);

  /// One cycle of the "live" dot's pulse ring.
  static const Duration livePulse = Duration(milliseconds: 2000);

  /// `cubic-bezier(0.2, 0.7, 0.2, 1)`.
  static const Curve curve = Cubic(0.2, 0.7, 0.2, 1);

  /// How far entering content rises, in design units.
  static const double enterOffsetY = 20;

  /// Whether the platform asked for reduced motion.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// [duration], or zero when motion is reduced, so every animation snaps
  /// to its final frame.
  static Duration of(BuildContext context, Duration duration) =>
      reduced(context) ? Duration.zero : duration;
}
