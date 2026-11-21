import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../style/app_colors.dart';

class AppNavigator {
  AppNavigator._();

  static GlobalKey<NavigatorState> _key = GlobalKey<NavigatorState>();

  /// The root navigator's key, set as `MaterialApp.navigatorKey`.
  ///
  /// A getter over a field that [renewKey] replaces: read it fresh on every
  /// use and never cache it (or its `currentState`) across a restart.
  static GlobalKey<NavigatorState> get key => _key;

  /// Gives the next `MaterialApp` a brand-new navigator key.
  ///
  /// Called by `AppRestart.restart()` just before it swaps the app's root key.
  /// If the restarted `MaterialApp` reused the old key, Flutter would reparent
  /// the old, still-inactive `NavigatorState` into it in the same build pass
  /// (`_retakeInactiveElement`) — keeping the old route stack — whenever
  /// `Localizations` builds its child synchronously. A fresh key makes the
  /// stack reset unconditional instead of depending on EasyLocalization's
  /// delegate happening to load asynchronously.
  static void renewKey() => _key = GlobalKey<NavigatorState>();

  static BuildContext get context {
    if (key.currentContext == null) {
      throw Exception('Context is not available');
    }
    return key.currentContext!;
  }

  static void push(Widget screen) async {
    await key.currentState?.push(CupertinoPageRoute(builder: (_) => screen));
  }

  static void replace(Widget screen) async {
    await key.currentState?.pushReplacement(
      CupertinoPageRoute(builder: (_) => screen),
    );
  }

  static void remove(Widget screen) async {
    await key.currentState?.pushAndRemoveUntil(
      CupertinoPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }

  static void pop() => key.currentState?.pop();

  static void sheet(Widget sheet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: sheet,
      ),
    );
  }

  static void dialog(Widget dialog) {
    showCupertinoDialog(
      barrierDismissible: true,
      // showCupertinoDialog ignores dialogTheme.barrierColor, so the spec's
      // navy-950 at 50 % is passed here.
      barrierColor: AppColors.navy950.withValues(alpha: 0.5),
      context: context,
      builder: (_) => dialog,
    );
  }
}
