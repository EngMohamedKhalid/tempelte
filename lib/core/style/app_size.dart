import 'dart:ui';

import 'package:flutter/material.dart';

import '../helper/app_navigator.dart';

/// Responsive sizing against the Figma design (375 x 812).
///
/// Metrics are read **per call** from the live [MediaQuery]. The original
/// version captured them once:
///
/// ```dart
/// static final Size _size = WidgetsBinding.instance.window.physicalSize /
///     WidgetsBinding.instance.window.devicePixelRatio;
/// ```
///
/// A `static final` is evaluated once per isolate, so every size the app was
/// ever asked about was the size it launched at — rotation, resize, folding
/// and split-screen all laid out against stale numbers, and the API it used is
/// deprecated besides.
///
/// The public API is unchanged: [getWidth], [getHeight], [getSize], [font],
/// [padding] and [margin] take the same arguments and mean the same thing, so
/// no call site needed touching.
class AppSize {
  AppSize._();

  /// REFERENCE VALUES FROM THE FIGMA DESIGN.
  static const num _designWidth = 375;
  static const num _designHeight = 812;
  static const num _designStatusBar = 44;

  /// The navigator's context, or null before the first frame — and, for one
  /// frame, during an `AppRestart` language-change key swap.
  ///
  /// `AppRestart` swaps the whole app's `KeyedSubtree` key to soft-restart it.
  /// Flutter defers unmounting the outgoing subtree
  /// (`BuildOwner.finalizeTree`) until *after* the new one is built, so for
  /// that one frame `AppNavigator.key` still resolves to the old, already
  /// deactivated `Navigator` element — and a `MediaQuery` lookup on it throws
  /// ("Looking up a deactivated widget's ancestor is unsafe"), which crashed
  /// every language change (F20 fix round 2). `AppRestart.restart()` now also
  /// renews `AppNavigator.key`, so during the swap the key has no context yet
  /// (null, handled below); this check stays as the safety net for any other
  /// frame where the navigator context is deactivated.
  ///
  /// `Element.debugIsActive` only computes inside its own `assert` and
  /// otherwise defaults to `false` — reading it directly would make every
  /// context look inactive in a release build. It is read from inside an
  /// `assert` here too, so profile and release builds (asserts are stripped
  /// in both) never run this check: there, a lookup on a deactivated context
  /// returns null instead of throwing, and AppSize falls back the same way.
  /// This codepath only exists for debug, where the underlying lookup assert
  /// would otherwise fire, and a deactivated context is treated the same as
  /// no context at all: fall back to the platform view for that one frame.
  static BuildContext? get _context {
    final BuildContext? context = AppNavigator.key.currentContext;
    bool active = context != null;
    assert(() {
      if (context is Element) active = context.debugIsActive;
      return true;
    }());
    return active ? context : null;
  }

  /// The platform view, used only before an element tree exists.
  static FlutterView get _view => PlatformDispatcher.instance.views.first;

  /// THE DEVICE VIEWPORT SIZE.
  ///
  /// Deliberately `MediaQuery.maybeSizeOf` and not `MediaQuery.maybeOf`.
  /// `maybeOf` subscribes to *every* aspect of the media query, including
  /// `viewInsets` — which changes every time the keyboard opens or closes. As
  /// the subscription is registered against the navigator, that would rebuild
  /// the whole route on every keystroke-adjacent event. The aspect-scoped
  /// accessors subscribe to one field each, so a rebuild only happens when
  /// that field actually changes: a rotate, a resize, a fold.
  static Size get _size {
    final BuildContext? context = _context;
    if (context != null) {
      final Size? size = MediaQuery.maybeSizeOf(context);
      if (size != null) return size;
    }
    return _view.physicalSize / _view.devicePixelRatio;
  }

  /// THE SYSTEM BAR INSETS.
  static EdgeInsets get _viewPadding {
    final BuildContext? context = _context;
    if (context != null) {
      final EdgeInsets? padding = MediaQuery.maybeViewPaddingOf(context);
      if (padding != null) return padding;
    }
    return EdgeInsets.fromViewPadding(
      _view.viewPadding,
      _view.devicePixelRatio,
    );
  }

  /// GET THE DEVICE VIEWPORT WIDTH.
  static double get _width => _size.width;

  /// GET THE DEVICE VIEWPORT HEIGHT, ACCOUNTING FOR STATUS BAR AND BOTTOM BAR.
  static double get _height {
    final EdgeInsets padding = _viewPadding;
    return _size.height - padding.top - padding.bottom;
  }

  /// THE DEVICE PIXEL RATIO.
  static double get devicePixelRatio {
    final BuildContext? context = _context;
    if (context != null) {
      final double? ratio = MediaQuery.maybeDevicePixelRatioOf(context);
      if (ratio != null) return ratio;
    }
    return _view.devicePixelRatio;
  }

  /// CALCULATE HORIZONTAL SIZE ACCORDING TO VIEWPORT WIDTH.
  static double getWidth(double px) => (px * _width) / _designWidth;

  /// CALCULATE VERTICAL SIZE ACCORDING TO VIEWPORT HEIGHT.
  static double getHeight(double px) =>
      (px * _height) / (_designHeight - _designStatusBar);

  /// GET THE SMALLEST SIZE FOR IMAGE HEIGHT AND WIDTH.
  static double getSize(double px) {
    final double vSize = getHeight(px);
    final double hSize = getWidth(px);
    return vSize < hSize ? vSize : hSize;
  }

  /// GET FONT SIZE ACCORDING TO VIEWPORT.
  static double font(double px) => getSize(px);

  /// CACHE WIDTH, IN DEVICE PIXELS, FOR AN IMAGE LAID OUT [logicalWidth] WIDE.
  ///
  /// Passing this to `cacheWidth` / `memCacheWidth` keeps a decoded bitmap at
  /// the size actually painted instead of the size it was authored at.
  static int cacheWidth(double logicalWidth) =>
      (logicalWidth * devicePixelRatio).round();

  /// SET PADDING RESPONSIVELY.
  static EdgeInsetsDirectional padding({
    double? all,
    double? top,
    double? end,
    double? start,
    double? bottom,
    double? vertical,
    double? horizontal,
  }) => _getMarginOrPadding(
    all: all,
    top: top,
    end: end,
    start: start,
    bottom: bottom,
    vertical: vertical,
    horizontal: horizontal,
  );

  /// SET MARGIN RESPONSIVELY.
  static EdgeInsetsDirectional margin({
    double? all,
    double? top,
    double? end,
    double? start,
    double? bottom,
    double? vertical,
    double? horizontal,
  }) => _getMarginOrPadding(
    all: all,
    top: top,
    end: end,
    start: start,
    bottom: bottom,
    vertical: vertical,
    horizontal: horizontal,
  );

  /// GET PADDING OR MARGIN RESPONSIVELY.
  static EdgeInsetsDirectional _getMarginOrPadding({
    double? all,
    double? top,
    double? end,
    double? start,
    double? bottom,
    double? vertical,
    double? horizontal,
  }) {
    final double t = top ?? vertical ?? all ?? 0;
    final double b = bottom ?? vertical ?? all ?? 0;
    final double s = start ?? horizontal ?? all ?? 0;
    final double e = end ?? horizontal ?? all ?? 0;
    return EdgeInsetsDirectional.only(
      top: getHeight(t),
      end: getWidth(e),
      bottom: getHeight(b),
      start: getWidth(s),
    );
  }
}
