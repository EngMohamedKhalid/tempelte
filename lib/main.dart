import 'package:easy_localization/easy_localization.dart';

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/helper/app_locals.dart';
import 'core/helper/app_navigator.dart';
import 'core/helper/app_restart.dart';
import 'core/helper/app_toast.dart';
import 'core/network/local/cache/cache_helper.dart';
import 'core/network/local/notifications/local_notifications.dart';
import 'core/network/remote/apis/dio_helper.dart';
import 'core/network/remote/firebase/firebase_messaging.dart';
import 'core/shared/controllers/theme/theme_cubit.dart';
import 'core/shared/features/user/controllers/user_cubit.dart';
import 'core/style/app_theme.dart';
import 'firebase_options.dart';
import 'features/shared/intro/presentation/screens/splash_screen.dart';
import 'features/shared/notifications/presentation/controller/notifications_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// FIREBASE INIT
  ///
  /// The project is `absher-park`, the shipped app's own — its
  /// `google-services.json`, `GoogleService-Info.plist` and
  /// `firebase_options.dart` came across with the platform identity, and both
  /// apps are registered to `com.absher.park`.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  /// CRASH REPORTING
  ///
  /// Live before the rollout widens — F17's exit is a crash-free rate at or
  /// above the shipped app's, and that cannot be measured without it. The
  /// legacy has no crash reporting at all, so its rate is known only from the
  /// stores' own consoles.
  ///
  /// Off in debug: a crash while developing is a stack trace in the terminal,
  /// and one in the dashboard is noise that hides a real one.
  final FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;
  await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
  // Errors inside the framework — a build or layout throwing.
  FlutterError.onError = crashlytics.recordFlutterFatalError;
  // Errors outside it — an unawaited future, a platform channel.
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    crashlytics.recordError(error, stack, fatal: true);
    return true;
  };

  /// SHARED PREFERENCES INIT
  await CacheHelper.init();

  /// LANGUAGE INIT
  await EasyLocalization.ensureInitialized();
  await AppLocales.init();
  // await CacheHelper.removeAll();

  /// API INIT [DIO]
  DioHelper.init();

  /// NOTIFICATIONS
  ///
  /// Not awaited. Both initialisers ask the platform for permission, and
  /// awaiting them holds the first frame behind a system dialog — the legacy
  /// `main()` blocks on these *and* on a location prompt before anything is
  /// drawn. The token and the listeners are wanted, not waited for; F13 owns
  /// the routing they feed.
  unawaited(FirebaseNotifications.initialize());
  unawaited(LocalNotificationService.initialize());

  /// SET DISABLE AUTO ROTATE
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    EasyLocalization(
      path: 'assets/translations',
      startLocale: AppLocales.currentLocale,
      fallbackLocale: AppLocales.currentLocale,
      supportedLocales: AppLocales.supportedLocales,
      // Real CLDR plural rules. The package default falls back to
      // zero/one/two/other, so Arabic never reached few (3–10) or many (11–99).
      ignorePluralRules: false,
      // Everything below this key is thrown away and rebuilt from splash on
      // AppRestart.restart() (a language change). EasyLocalization stays
      // above it so the chosen locale survives the restart. restart() also
      // renews AppNavigator.key and AppToast.messengerKey, so the new
      // MaterialApp never reparents the old navigator (see AppRestart).
      child: ValueListenableBuilder<Key>(
        valueListenable: AppRestart.key,
        builder: (BuildContext context, Key key, Widget? child) =>
            KeyedSubtree(key: key, child: const MyApp()),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => UserCubit()),
        // Above the navigator and for the life of the app: a push arrives
        // whenever it arrives, including before any screen exists.
        BlocProvider(create: (_) => ThemeCubit()..getSettings()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        buildWhen: (previous, current) => current is ThemeInitial,
        builder: (context, state) {
          final cubit = ThemeCubit.get(context);
          return MaterialApp(
            themeMode: cubit.mode,
            theme: AppTheme.light,
            locale: context.locale,
            title: 'App Name',
            darkTheme: AppTheme.dark,
            home: const SplashScreen(),
            navigatorKey: AppNavigator.key,
            scaffoldMessengerKey: AppToast.messengerKey,
            debugShowCheckedModeBanner: false,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
          );
        },
      ),
    );
  }
}
