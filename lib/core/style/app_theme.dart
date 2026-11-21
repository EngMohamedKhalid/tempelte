import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_size.dart';
import 'app_tokens.dart';

/// The app's two themes, built from the design-system tokens.
///
/// **F19, 2026-09-27.** Rebuilt from `design/design-tokens.json` on
/// Material 3. The names are the legacy core's; everything inside is new.
///
/// Getters rather than `static final` fields: sizes go through `AppSize`,
/// which reads the live viewport, and a field would freeze them at whatever
/// size the first read happened to see.
///
/// Built from token **constants** only, never the `AppColors` getters: those
/// read the cached theme flag, and a theme must be the same object whatever
/// that flag says.
class AppTheme {
  AppTheme._();

  /// The light theme.
  static ThemeData get light => _build(Brightness.light);

  /// The dark theme — derived from the navy scale; the accent is brand-500.
  static ThemeData get dark => _build(Brightness.dark);

  /// Marks every element in the tree as needing a build.
  ///
  /// Widgets that read an `AppColors` getter do not depend on `Theme.of`, so
  /// a new `MaterialApp.theme` alone never reaches them — after switching to
  /// dark, a pushed route would keep its light text. This walks the tree once,
  /// on a theme switch, which is rare enough that the cost does not matter.
  static void rebuildAll() {
    void mark(Element element) {
      element.markNeedsBuild();
      element.visitChildren(mark);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(mark);
  }

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.navy800,
    onPrimary: AppColors.white,
    secondary: AppColors.brand500,
    onSecondary: AppColors.navy950,
    tertiary: AppColors.navy700,
    onTertiary: AppColors.white,
    error: AppColors.dangerText,
    onError: AppColors.white,
    surface: AppColors.white,
    onSurface: AppColors.navy900,
    onSurfaceVariant: AppColors.navy500,
    surfaceContainerHighest: AppColors.navy50,
    outline: AppColors.navy200,
    outlineVariant: AppColors.navy100,
    shadow: AppColors.navy950,
    scrim: AppColors.navy950,
    inverseSurface: AppColors.navy900,
    onInverseSurface: AppColors.white,
    surfaceTint: Colors.transparent,
  );

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.brand500,
    onPrimary: AppColors.navy950,
    secondary: AppColors.brand500,
    onSecondary: AppColors.navy950,
    tertiary: AppColors.navy300,
    onTertiary: AppColors.navy950,
    error: AppColors.dangerBorder,
    onError: AppColors.navy950,
    surface: AppColors.navy900,
    onSurface: AppColors.navy50,
    onSurfaceVariant: AppColors.navy200,
    surfaceContainerHighest: AppColors.navy800,
    outline: AppColors.navy700,
    outlineVariant: AppColors.navy800,
    shadow: Colors.black,
    scrim: AppColors.navy950,
    inverseSurface: AppColors.navy50,
    onInverseSurface: AppColors.navy900,
    surfaceTint: Colors.transparent,
  );

  static TextStyle _style(double size, FontWeight weight, Color color,
      {double? height}) {
    return TextStyle(
      fontFamily: 'Tajawal',
      fontSize: AppSize.font(size),
      fontWeight: weight,
      color: color,
      height: height,
      // Tajawal ships no `tnum` feature today, so this is a no-op — kept so
      // numbers line up the day the typeface does.
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    );
  }

  static ThemeData _build(Brightness brightness) {
    final bool dark = brightness == Brightness.dark;
    final ColorScheme scheme = dark ? _darkScheme : _lightScheme;

    final Color text = dark ? AppColors.navy50 : AppColors.navy900;
    final Color muted = dark ? AppColors.navy200 : AppColors.navy500;
    final Color label = dark ? AppColors.navy100 : AppColors.navy700;
    final Color scaffold = dark ? AppColors.navy950 : AppColors.scaffold;
    final Color surface = dark ? AppColors.navy900 : AppColors.white;
    final Color border = dark ? AppColors.navy800 : AppColors.navy100;
    final Color control = dark ? AppColors.navy700 : AppColors.navy200;
    final Color placeholder = dark ? AppColors.navy400 : AppColors.navy300;
    final Color errorText = dark ? AppColors.dangerBorder : AppColors.dangerText;

    final TextTheme textTheme = TextTheme(
      displaySmall: _style(30, FontWeight.w900, text),
      titleLarge: _style(18, FontWeight.w700, text),
      titleMedium: _style(16, FontWeight.w700, text),
      titleSmall: _style(14, FontWeight.w700, text),
      bodyLarge: _style(16, FontWeight.w400, text),
      bodyMedium: _style(14, FontWeight.w400, text),
      bodySmall: _style(12, FontWeight.w400, muted),
      labelLarge: _style(14, FontWeight.w700, text),
      labelMedium: _style(14, FontWeight.w500, label),
      labelSmall: _style(12, FontWeight.w700, text, height: 20 / 12),
    );

    final BorderRadius controlRadius =
        BorderRadius.circular(AppSize.getSize(AppRadius.control));
    final BorderRadius cardRadius =
        BorderRadius.circular(AppSize.getSize(AppRadius.card));

    OutlineInputBorder outline(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: controlRadius,
      borderSide: BorderSide(color: c, width: w),
    );

    final Brightness iconBrightness =
        dark ? Brightness.light : Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: 'Tajawal',
      textTheme: textTheme,
      scaffoldBackgroundColor: scaffold,
      focusColor: AppColors.brand500,
      splashFactory: NoSplash.splashFactory,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        // Material's default. The copied theme set 0, which put a root
        // screen's title flush against the display edge.
        titleSpacing: 16,
        centerTitle: false,
        backgroundColor: surface,
        foregroundColor: text,
        titleTextStyle: textTheme.titleMedium,
        iconTheme: IconThemeData(color: text),
        // The spec's scrolled-under state, minus the blur: a hairline.
        shape: Border(bottom: BorderSide(color: border)),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: surface,
          systemNavigationBarColor: surface,
          statusBarBrightness: Platform.isIOS ? brightness : iconBrightness,
          statusBarIconBrightness: iconBrightness,
          systemNavigationBarIconBrightness: iconBrightness,
        ),
      ),
      // `InputDecorationTheme` in the brief; `ThemeData.inputDecorationTheme`
      // in this Flutter (3.47) takes `InputDecorationThemeData` — the field
      // was renamed to match the `FooThemeData` convention.
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: surface,
        isDense: true,
        errorMaxLines: 5,
        contentPadding: AppSize.padding(
          horizontal: AppSpacing.controlPaddingH,
          vertical: AppSpacing.controlPaddingV,
        ),
        hintStyle: textTheme.bodyMedium!.copyWith(color: placeholder),
        labelStyle: textTheme.labelMedium,
        floatingLabelStyle: textTheme.labelMedium,
        errorStyle: _style(14, FontWeight.w500, errorText),
        border: outline(control),
        enabledBorder: outline(control),
        focusedBorder: outline(AppColors.brand500, 2),
        errorBorder: outline(AppColors.dangerBorder),
        focusedErrorBorder: outline(AppColors.dangerBorder, 2),
        disabledBorder: outline(border),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(0, AppSpacing.minTouch),
          shape: RoundedRectangleBorder(borderRadius: controlRadius),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: surface,
          foregroundColor: dark ? AppColors.navy50 : AppColors.navy800,
          side: BorderSide(color: control),
          minimumSize: const Size(0, AppSpacing.minTouch),
          shape: RoundedRectangleBorder(borderRadius: controlRadius),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: dark ? AppColors.navy100 : AppColors.navy700,
          minimumSize: const Size(0, AppSpacing.minTouch),
          shape: RoundedRectangleBorder(borderRadius: controlRadius),
          textStyle: textTheme.labelLarge,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll<Color>(AppColors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> s) => s.contains(WidgetState.selected)
              ? AppColors.brand500
              : control,
        ),
        trackOutlineColor:
            const WidgetStatePropertyAll<Color>(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.getSize(6)),
        ),
        side: BorderSide(color: control),
        fillColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> s) => s.contains(WidgetState.selected)
              ? AppColors.brand500
              : surface,
        ),
        checkColor: const WidgetStatePropertyAll<Color>(AppColors.navy950),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> s) => s.contains(WidgetState.selected)
              ? AppColors.brand500
              : control,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: cardRadius,
          side: BorderSide(color: border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        barrierColor: AppColors.navy950.withValues(alpha: 0.5),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium!.copyWith(
          color: dark ? AppColors.navy100 : AppColors.navy700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: cardRadius,
          side: BorderSide(color: border),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.navy900,
        contentTextStyle: _style(14, FontWeight.w500, AppColors.white),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        // Dark: a navy-700 edge, or the navy-900 toast vanishes into the
        // navy-900/950 ground.
        shape: RoundedRectangleBorder(
          borderRadius: controlRadius,
          side: dark
              ? const BorderSide(color: AppColors.navy700)
              : BorderSide.none,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: dark ? AppColors.navy800 : AppColors.navy100,
        selectedColor: AppColors.brand500,
        labelStyle: textTheme.labelSmall,
        side: BorderSide.none,
        shape: const StadiumBorder(),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        backgroundColor: surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: muted,
        selectedLabelStyle: _style(12, FontWeight.w700, scheme.primary),
        unselectedLabelStyle: _style(12, FontWeight.w400, muted),
      ),
      // F26: the active tab is a navy-800 pill with a green icon; icons and
      // labels stay. Both shells read this, so they cannot drift apart.
      // F26, owner round 2: the bar is the header's navy (both themes), the
      // active tab a green pill with a dark icon; icons and labels stay.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.navy800,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: AppColors.brand500,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? AppColors.navy950 : AppColors.navy200,
            size: AppSize.getSize(24),
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? _style(12, FontWeight.w700, AppColors.white)
              : _style(12, FontWeight.w500, AppColors.navy200),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSize.getSize(AppRadius.card)),
          ),
        ),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        collapsedBackgroundColor: surface,
        backgroundColor: surface,
        collapsedIconColor: text,
        iconColor: text,
        collapsedTextColor: text,
        textColor: text,
        tilePadding: EdgeInsets.zero,
        childrenPadding: AppSize.padding(bottom: 12),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
      ),
    );
  }
}
