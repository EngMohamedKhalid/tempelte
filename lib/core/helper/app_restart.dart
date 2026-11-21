import 'package:flutter/widgets.dart';

import 'app_navigator.dart';
import 'app_toast.dart';

/// Restarts the app in place — a soft restart to the splash screen.
///
/// `main.dart` puts [key] on a `KeyedSubtree` directly under
/// `EasyLocalization`. Swapping it throws away everything below — the root
/// cubits, `MaterialApp`, the navigator stack — and builds it again from
/// `SplashScreen`, exactly like a cold start, while the chosen locale (held by
/// `EasyLocalization`, above the key) survives.
///
/// The navigator and messenger `GlobalKey`s are renewed first. A `GlobalKey`
/// found on an inactive element in the same build pass is reparented, not
/// recreated, so reusing them would carry the old `NavigatorState` (its route
/// stack) and `ScaffoldMessengerState` into the new `MaterialApp` whenever
/// `Localizations` builds its child synchronously. With fresh keys the reset
/// holds however the localization delegates load.
///
/// Used after a language change (F20, owner decision E1): every screen is
/// rebuilt and re-fetches, so server text comes back in the new language too.
abstract final class AppRestart {
  /// The key on the app's root subtree. A new value remounts the app.
  static final ValueNotifier<Key> key = ValueNotifier<Key>(UniqueKey());

  /// Rebuilds the whole app from splash, with fresh root `GlobalKey`s.
  static void restart() {
    AppNavigator.renewKey();
    AppToast.renewKey();
    key.value = UniqueKey();
  }
}
