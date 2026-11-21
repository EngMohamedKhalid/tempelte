import 'dart:developer';

import 'package:absher_park/core/helper/app_navigator.dart';
import 'package:absher_park/core/helper/app_toast.dart';
import 'package:absher_park/features/shared/intro/presentation/screens/splash_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../helper/app_locals.dart';
import '../../errors/failure.dart';
import '../../local/cache/cache_helper.dart';
import '../../local/cache/cache_keys.dart';

/// Attaches the token and the active locale to every request.
class AppInterceptors extends Interceptor {
  final Dio dio;

  AppInterceptors(this.dio);

  /// On [REQUEST] API
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final String? token = await CacheHelper.get(CacheKeys.token);
    options.headers.addAll({
      'Accept': 'application/json',
      'Accept-Language': AppLocales.currentLocale.languageCode,
      if (token != null) 'Authorization': 'Bearer $token',
    });
    return handler.next(options);
  }
}

/// Classifies every failed request, once.
///
/// This is the only place in the app that reads a status code. Repositories
/// keep their existing shape — they already end with
/// `left(ServerFailure.fromCatchError(e))`, and the typed failure produced
/// here travels out on `DioException.error` for that factory to unwrap.
///
/// The session handling moved here from `onResponse`. With `validateStatus`
/// accepting only 2xx, a 401 never reaches a response handler any more.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final ServerFailure failure = _classify(err);
    // A 401 is the only failure that ends the session.
    //
    // A 402 must not: that is the *venue's* platform licence lapsing, which is
    // a billing condition the user cannot act on and did not cause. Signing
    // them out would punish the wrong person, and they would simply sign back
    // in to the same wall.
    if (failure is UnauthorizedFailure) {
      await CacheHelper.remove(CacheKeys.token);
      // Said here because here is the only place it can still be said. The
      // screen underneath is about to be replaced, so a cubit that reports
      // its own failures never gets to render one — it emits into a tree that
      // is being torn down, and the user lands back on sign-in with no
      // explanation at all.
      AppToast.error(failure.errMessage);
      if (AppNavigator.key.currentState != null) {
        AppNavigator.remove(const SplashScreen());
      }
    }

    return handler.reject(
      DioException(
        error: failure,
        type: err.type,
        response: err.response,
        requestOptions: err.requestOptions,
      ),
    );
  }

  ServerFailure _classify(DioException err) {
    final ServerFailure failure = ServerFailure.fromDioError(err);

    // Name the host and the underlying OS error in debug builds. A request
    // that cannot leave the device says nothing useful on its own, and the
    // difference between "no signal" and "that host does not exist" is the
    // whole diagnosis.
    if (kDebugMode && failure is NetworkFailure) {
      log(
        'could not reach ${err.requestOptions.uri} — ${err.error}',
        name: 'network',
      );
    }

    // Carry the retry window across so an OTP screen can show it.
    if (failure is RateLimitedFailure) {
      final String? header = err.response?.headers.value('retry-after');
      final int? seconds = header == null ? null : int.tryParse(header);
      if (seconds != null) {
        return RateLimitedFailure(
          failure.errMessage,
          retryAfter: Duration(seconds: seconds),
        );
      }
    }
    return failure;
  }
}
