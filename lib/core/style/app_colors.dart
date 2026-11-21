import 'package:flutter/material.dart';

import '../network/local/cache/cache_helper.dart';
import 'app_tone.dart';

class AppColors {
  static bool isDark() => CacheHelper.get('theme') == 'dark';

  static Color shimmerLoading() {
    bool isDark = CacheHelper.get('theme') == 'dark';
    return isDark
        ? Colors.white.withValues(alpha: 0.25)
        : Colors.black.withValues(alpha: 0.25);
  }

  /// Parses `#AARRGGBB` or `#RRGGBB` into a colour.
  ///
  /// [fallback] is returned for anything unparseable rather than throwing. Car
  /// colours arrive from the server as free text, and the legacy `int.parse`
  /// takes the whole list down with a FormatException the first time one of
  /// them reads `red` instead of `#ff0000`.
  static Color getColorFromHex(String hexColor, {Color fallback = Colors.black}) {
    if (hexColor.isEmpty) return fallback;
    hexColor = hexColor.replaceAll("#", ""); // Remove #
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor"; // Add full opacity if alpha is missing
    }
    if (hexColor.length != 8) return fallback;
    final int? value = int.tryParse(hexColor, radix: 16);
    return value == null ? fallback : Color(value);
  }

  /// The inverse: a colour as `#AARRGGBB`, which is the shape the server
  /// stores and [getColorFromHex] reads back.
  ///
  /// One helper, here. The legacy builds this string inline in two different
  /// cubits, both off the deprecated `.alpha`/`.red`/`.green`/`.blue`
  /// accessors.
  static String toHex(Color color) =>
      '#${color.toARGB32().toRadixString(16).padLeft(8, '0')}';

  /// WCAG contrast ratio between two opaque colours, 1–21.
  static double contrast(Color a, Color b) {
    final double la = a.computeLuminance();
    final double lb = b.computeLuminance();
    final double hi = la > lb ? la : lb;
    final double lo = la > lb ? lb : la;
    return (hi + 0.05) / (lo + 0.05);
  }

  // ─── DESIGN SYSTEM SCALES ─────────────────────────────────────────────────
  // Exported from the web (`absherpark_new_web`, 2026-09-27). The single source
  // of truth is `design/design-tokens.json`; `design_tokens_test.dart` reads
  // that file, so these cannot drift from it silently.

  static const Color navy50 = Color(0xFFF1F4FA);
  static const Color navy100 = Color(0xFFDDE5F3);
  static const Color navy200 = Color(0xFFC1D0E9);
  /// Placeholders and inactive glyphs only — 3.1:1 on white, never text.
  static const Color navy300 = Color(0xFF7B93C4);
  /// Decorative icons and the "—" empty value only — 4.2:1, never text.
  static const Color navy400 = Color(0xFF5F7CB4);
  static const Color navy500 = Color(0xFF3E5B92);
  static const Color navy600 = Color(0xFF1E3A70);
  static const Color navy700 = Color(0xFF162F60);
  static const Color navy800 = Color(0xFF0D2350);
  static const Color navy900 = Color(0xFF081838);
  static const Color navy950 = Color(0xFF050F24);

  static const Color brand300 = Color(0xFFB7E06F);
  static const Color brand400 = Color(0xFFA3D955);
  static const Color brand500 = Color(0xFF8CC63F);
  static const Color brand600 = Color(0xFF74A831);
  /// Icons only: as text on white it is 4.35:1, under the 4.5 floor.
  static const Color brand700 = Color(0xFF5B8526);

  static const Color amber400 = Color(0xFFF5B53F);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerPressed = Color(0xFFB91C1C);
  static const Color dangerText = Color(0xFFB91C1C);
  static const Color dangerBorder = Color(0xFFF87171);
  static const Color scaffold = Color(0xFFF5F7FB);
  static const Color heroNavy = Color(0xFF0B1633);

  /// The navy scale by step, for code that picks a step by number.
  static const Map<int, Color> navy = <int, Color>{
    50: navy50, 100: navy100, 200: navy200, 300: navy300, 400: navy400,
    500: navy500, 600: navy600, 700: navy700, 800: navy800, 900: navy900,
    950: navy950,
  };

  /// The brand-green scale by step.
  static const Map<int, Color> brand = <int, Color>{
    300: brand300, 400: brand400, 500: brand500, 600: brand600, 700: brand700,
  };

  // ─── LEGACY NAMES, RE-VALUED TO THE DESIGN SYSTEM (F19, 2026-09-27) ───────
  // The names are the legacy core's and are kept on the owner's decision, so
  // every existing `AppColors.xxx` call restyles without an edit. The values
  // now come from the scales above. Gold (#C79C6B) is gone: the dark-mode
  // accent is brand-500.

  // Shared Colors
  static const Color primaryLight = navy800;
  static const Color primaryDark = brand500;
  static const Color secondaryLight = brand500;
  static const Color secondaryDark = brand500;
  static const Color tertiaryLight = navy700;
  static const Color tertiaryDark = navy800;
  static const Color white = Color(0xffffffff);
  static const Color black = Color(0xff000000);

  static const Color grey81 = navy500;
  static const Color greyC8 = navy200;
  static const Color scaffoldBackground = scaffold;

  // Splash bg
  static const Color splashBackgroundLight = heroNavy;
  static const Color splashBackgroundDark = heroNavy;

  // Background Colors
  static const Color backgroundPrimaryLight = scaffold;
  static const Color backgroundPrimaryDark = navy950;
  static const Color backgroundSecondaryLight = white;
  static const Color backgroundSecondaryDark = navy900;
  static const Color backgroundTertiaryLight = navy900;
  static const Color backgroundTertiaryDark = navy800;

  // Typography Colors
  static const Color typographyHeadingLight = navy900;
  /// Form labels.
  static const Color typographyHeadingLight2 = navy700;
  static const Color typographyHeadingDark = navy50;
  static const Color typographySubtitleLight = navy500;
  static const Color typographySubtitleDark = navy200;
  static const Color typographyBodyLight = navy900;
  static const Color typographyBodyDark = navy100;

  // Button Colors
  static const Color buttonPrimaryLight = navy800;
  static const Color buttonPrimaryDark = brand500;
  static const Color buttonSecondaryLight = navy700;
  static const Color buttonSecondaryDark = navy800;
  static const Color buttonLabelLight = white;
  static const Color buttonLabelDark = navy950;
  static const Color buttonOutlineLight = navy200;
  static const Color buttonOutlineDark = navy700;
  static const Color buttonDisabled = navy200;

  // Icon Colors
  static const Color iconPrimaryLight = navy900;
  static const Color iconPrimaryDark = navy50;
  /// Icons only — see [brand700]. Green *text* uses `AppTone.green.fg`.
  static const Color iconSuccess = brand700;
  /// Decorative only — see [navy400].
  static const Color iconGray = navy400;
  static const Color iconWarning = Color(0xFF92400E);
  static const Color iconDanger = dangerText;

  // Input Colors
  static const Color inputBackgroundLight = white;
  static const Color inputBackgroundDark = navy900;
  static const Color inputPlaceholderLight = navy300;
  static const Color inputPlaceholderDark = navy400;
  static const Color inputOutlineLight = navy200;
  static const Color inputOutlineDark = navy700;

  // Separating Colors
  static const Color separatingPrimaryBorderLight = navy100;
  static const Color separatingPrimaryBorderDark = navy800;
  static const Color separatingSecondaryBorderLight = brand500;
  static const Color separatingSecondaryBorderDark = brand500;
  static const Color separatingSeparatorLight = navy100;
  static const Color separatingSeparatorDark = navy900;

  //COLORS I ADDED

  static const Color textWarning = amber400;
  static const Color notificationColor = danger;

  // Getters for dynamic colors based on theme
  /// F26 header bands. The same in both themes — they are already dark.
  static Color get headerCustomer => navy800;
  /// Near-black in light; navy-800 in dark, where navy-950 is the page.
  static Color get headerStaff => isDark() ? navy800 : navy950;
  static Color get headerEyebrow => brand400;
  static Color get headerControl => navy600;

  static Color get primary => isDark() ? primaryDark : primaryLight;

  static Color get secondary => isDark() ? secondaryDark : secondaryLight;

  static Color get tertiary => isDark() ? tertiaryDark : tertiaryLight;

  static Color get splashBackground =>
      isDark() ? splashBackgroundDark : splashBackgroundLight;

  static Color get backgroundPrimary =>
      isDark() ? backgroundPrimaryDark : backgroundPrimaryLight;

  static Color get backgroundSecondary =>
      isDark() ? backgroundSecondaryDark : backgroundSecondaryLight;

  static Color get backgroundTertiary =>
      isDark() ? backgroundTertiaryDark : backgroundTertiaryLight;

  static Color get typographyHeading =>
      isDark() ? typographyHeadingDark : typographyHeadingLight;

  static Color get typographySubtitle =>
      isDark() ? typographySubtitleDark : typographySubtitleLight;

  static Color get typographyBody =>
      isDark() ? typographyBodyDark : typographyBodyLight;

  static Color get buttonPrimary =>
      isDark() ? buttonPrimaryDark : buttonPrimaryLight;

  static Color get buttonSecondary =>
      isDark() ? buttonSecondaryDark : buttonSecondaryLight;

  static Color get buttonLabel => isDark() ? buttonLabelDark : buttonLabelLight;

  static Color get buttonOutline =>
      isDark() ? buttonOutlineDark : buttonOutlineLight;

  static Color get iconPrimary => isDark() ? iconPrimaryDark : iconPrimaryLight;

  static Color get inputBackground =>
      isDark() ? inputBackgroundDark : inputBackgroundLight;

  static Color get inputPlaceholder =>
      isDark() ? inputPlaceholderDark : inputPlaceholderLight;

  static Color get inputOutline =>
      isDark() ? inputOutlineDark : inputOutlineLight;

  static Color get separatingPrimaryBorder =>
      isDark() ? separatingPrimaryBorderDark : separatingPrimaryBorderLight;

  static Color get separatingSecondaryBorder =>
      isDark() ? separatingSecondaryBorderDark : separatingSecondaryBorderLight;

  static Color get separatingSeparator =>
      isDark() ? separatingSeparatorDark : separatingSeparatorLight;

  // ─── DARK-AWARE TEXT GETTERS (F19 final review) ───────────────────────────
  // The raw scale constants above are light-only. Text that sits on a themed
  // surface goes through one of these so it stays readable in dark mode.
  // `contrast_test.dart` holds each one to 4.5:1 on both themes' surfaces.

  /// Readable red for failure sentences and money that is owed.
  ///
  /// Light: [dangerText] (6.5:1 on white). Dark: [dangerBorder], because
  /// [dangerText] is 2.7:1 on navy-900.
  static Color get errorText => isDark() ? dangerBorder : dangerText;

  /// Readable green text ("Paid", a discount, "car ready").
  ///
  /// Light: `AppTone.green.fg` #065F46 (brand-700 is 4.35:1, icons only).
  /// Dark: [brand400], because #065F46 is 2.3:1 on navy-900.
  static Color get successText => isDark() ? brand400 : AppTone.green.fg;

  /// Quiet text on a completed board row.
  ///
  /// Light: [navy500] (navy-400 is 4.2:1). Dark: [navy300], 5.7:1 on
  /// navy-900 and 6.2:1 on navy-950.
  static Color get quietText => isDark() ? navy300 : navy500;

  /// Form-field labels: [typographyHeadingLight2] (navy-700) in light,
  /// [navy100] in dark.
  static Color get typographyLabel =>
      isDark() ? navy100 : typographyHeadingLight2;
}
