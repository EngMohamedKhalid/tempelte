import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../style/app_colors.dart';
import '../style/app_size.dart';
import '../style/app_tokens.dart';

/// Context-free toasts — the legacy API, now a themed SnackBar (F19).
///
/// Shown through [messengerKey], set as `MaterialApp.scaffoldMessengerKey`,
/// the same pattern as `AppNavigator.key`. A root messenger carries a toast
/// across a route replacement, so the 401 message still shows after the
/// interceptor sends the user back to splash.
///
/// Error and success differ by icon and label, never by fill colour alone.
class AppToast {
  AppToast._();

  static GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// The app's root messenger.
  ///
  /// A getter over a field that [renewKey] replaces: read it fresh on every
  /// use and never cache it across a restart.
  static GlobalKey<ScaffoldMessengerState> get messengerKey => _messengerKey;

  /// Gives the next `MaterialApp` a brand-new messenger key.
  ///
  /// Called by `AppRestart.restart()` just before it swaps the app's root key,
  /// for the same reason as `AppNavigator.renewKey`: a reused GlobalKey lets
  /// Flutter reparent the old `ScaffoldMessengerState` (and any SnackBar it
  /// is showing) into the restarted app.
  static void renewKey() =>
      _messengerKey = GlobalKey<ScaffoldMessengerState>();

  /// A failure the user should know about.
  static void error(String msg) => _show(msg, isError: true);

  /// Something finished.
  static void success(String msg) => _show(msg, isError: false);

  static void _show(String msg, {required bool isError}) {
    final ScaffoldMessengerState? messenger = messengerKey.currentState;
    // No app mounted — a cubit under test. Nothing to show it on.
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: AppMotion.toastDismiss,
          padding: AppSize.padding(horizontal: 16, vertical: 12),
          content: Row(
            children: <Widget>[
              // A boundary of its own: the SnackBar wraps its content in a
              // single merging `Semantics(container: true)`, so an icon
              // label given through `Icon.semanticLabel` alone would merge
              // into one node with the message text below it. `container:
              // true` here keeps "Error"/"Done" readable on its own.
              Semantics(
                container: true,
                label: (isError ? 'core.toast_error' : 'core.toast_success').tr(),
                child: Icon(
                  isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                  size: AppSize.getSize(20),
                  color: isError ? AppColors.dangerBorder : AppColors.brand400,
                ),
              ),
              SizedBox(width: AppSize.getWidth(12)),
              Expanded(child: Text(msg)),
            ],
          ),
        ),
      );
  }
}
