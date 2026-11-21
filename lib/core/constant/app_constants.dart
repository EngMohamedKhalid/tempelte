// ignore_for_file: unused_element
import 'dart:io';

/// Values that are fixed for the app but belong to no single feature.
class AppConstants {
  AppConstants._();

  /// Android application id. Must match `applicationId` in build.gradle.kts.
  static const String androidPackage = 'com.absher.park';

  /// Apple App Store numeric id.
  static const String appStoreId = '6745216539';

  /// The tenant's VAT registration number, printed on every receipt.
  ///
  /// The legacy hardcodes this inside the invoice widget, twice, in Arabic
  /// text — so a second tenant, or a change of registration, means editing a
  /// screen. It is configuration: override it at build time with
  /// `--dart-define=VAT_NUMBER=…`.
  static const String vatNumber = String.fromEnvironment(
    'VAT_NUMBER',
    defaultValue: '311243365200003',
  );

  /// The store page for the current platform.
  static String get storeUrl => Platform.isIOS
      ? 'https://apps.apple.com/app/id$appStoreId'
      : 'https://play.google.com/store/apps/details?id=$androidPackage';
}
