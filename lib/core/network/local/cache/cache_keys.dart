class CacheKeys {
  static const String lang = 'lang';
  static const String langAr = 'ar';
  static const String langEN = 'en';

  static const String theme = 'theme';
  static const String themeDark = 'dark';
  static const String themeLight = 'light';

  static const String token = 'token';

  /// Set while browsing on the shared guest account.
  static const String guest = 'guest';

  static const String user = 'user';

  static const String fcmToken = 'fcm_token';

  /// The signed-in account's role, refreshed on every `/me`.
  ///
  /// Written so the push handlers can tell a customer from a staff member
  /// without a `BuildContext` — a tap arrives before any screen exists.
  static const String role = 'role';

  static const String firstUse = 'first_use';
}
