import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';

import '../network/local/cache/cache_helper.dart';
import 'app_navigator.dart';

class AppLocales {
  /// CURRENT LANG
  static int? currentLang;

  static Future<void> init() async {
    /// GET DEVICE LANG CODE
    String languageCode = Intl.systemLocale.split('_')[0];

    /// SAVE DEFAULT LANG
    await CacheHelper.get('lang') ??
        await CacheHelper.save(
          'lang',
          languageCode == 'ar' ||
                  languageCode == 'en' ||
                  languageCode == 'ur' ||
                  languageCode == 'bn'
              ? languageCode
              : 'ar',
        );

    /// GET LANG
    String lang = await CacheHelper.get('lang');

    /// CURRENT LANG
    if (lang == 'ar') {
      currentLang = 0;
    } else if (lang == 'en') {
      currentLang = 1;
    } else if (lang == 'ur') {
      currentLang = 2;
    } else if (lang == 'bn') {
      currentLang = 3;
    }
  }

  /// LIST OF SUPPORTED LOCALES
  static const supportedLocales = [
    Locale('ar', 'EG'),
    Locale('en', 'US'),
    Locale('ur', 'PK'),
    Locale('bn', 'BD'),
  ];

  /// LIST OF SUPPORTED LOCALES NAMES
  static const supportedLocalesNames = ['العربية', 'English', 'اردو', 'বাংলা'];

  /// LIST OF SUPPORTED LOCALES CODES
  static const supportedLocalesCodes = ['ar', 'en', 'ur', 'bn'];

  /// CURRENT APP LOCALE
  ///
  /// **Core delta, 2026-09-23.** This was a static *field*,
  /// `supportedLocales[currentLang!]`, and a Dart static field runs its
  /// initialiser on first read — so anything touching the locale before
  /// [init] had run threw `Null check operator used on a null value`, from a
  /// stack trace naming this line and nothing about the caller. It is not
  /// hypothetical: it took down six model tests the moment
  /// `ParkingModel.displayName` started asking what language the reader is in,
  /// because a model test has no app to boot.
  ///
  /// Two things change. It **derives** from [currentLang] rather than caching
  /// a copy, so it can never go stale against the value
  /// `AppInterceptors` reads for `Accept-Language`; and it falls back to
  /// Arabic — the same default [init] itself picks for an unsupported device
  /// language — instead of throwing.
  ///
  /// It stays assignable, because the setter is how a test states the language
  /// it is exercising. Assigning writes through to [currentLang], so the two
  /// cannot disagree.
  static Locale get currentLocale =>
      supportedLocales[currentLang ?? _defaultLang];

  static set currentLocale(Locale locale) {
    final int index = supportedLocalesCodes.indexOf(locale.languageCode);
    if (index != -1) currentLang = index;
  }

  /// Arabic. The app's own default, and what [init] falls back to.
  static const int _defaultLang = 0;

  /// Switches the app's locale. Completes once the new locale is applied, so
  /// a caller can restart the app knowing it will come back in that
  /// language.
  ///
  /// Reads the navigator's context directly rather than through
  /// `AppNavigator.context`, which throws when there is none: the locale is
  /// also set from a cubit, and a language change must not take down the app
  /// because no tree is mounted yet — it just bails to the cached locale.
  static Future<void> setDeviceLocale(int index) async {
    if (index < 0 || index >= supportedLocales.length) return;
    currentLang = index;
    final BuildContext? context = AppNavigator.key.currentContext;
    final dynamic controller = context == null
        ? null
        : EasyLocalization.of(context);
    if (controller == null) {
      currentLocale = supportedLocales[index];
      return;
    }
    await controller.setLocale(supportedLocales[index]);
    currentLocale = supportedLocales[index];
  }
}
