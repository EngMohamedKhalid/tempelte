import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

abstract class Failure {
  final String errMessage;

  const Failure(this.errMessage);
}

/// Anything the server or the transport did wrong.
///
/// The typed failures below all extend this, which is what lets the existing
/// repositories keep their shape. They already end every call with
/// `left(ServerFailure.fromCatchError(e))`, and that factory now hands back the
/// specific subtype — so a caller that wants to know gets
/// `UnauthorizedFailure` or `LicenceSuspendedFailure`, and a caller that only
/// wants a message carries on reading `errMessage`.
class ServerFailure extends Failure {
  ServerFailure(super.errMessage, {this.statusCode});

  /// The HTTP status this came from, when it came from one.
  final int? statusCode;

  /// Maps a status code to the failure that describes it.
  ///
  /// [message] is the server's own wording when it sent any; it reads better
  /// than anything held locally, so it wins.
  factory ServerFailure.fromStatusCode(int? code, [String? message]) {
    String text(String key) =>
        (message != null && message.isNotEmpty) ? message : key.tr();

    switch (code) {
      case 401:
        return UnauthorizedFailure(text('failure.unauthorized'));
      case 402:
        return LicenceSuspendedFailure(text('failure.licence_suspended'));
      case 403:
        return ForbiddenFailure(text('failure.forbidden'));
      case 404:
        return NotFoundFailure(text('failure.not_found'));
      case 422:
        return ValidationFailure(text('failure.validation'));
      case 429:
        return RateLimitedFailure(text('failure.rate_limited'));
      default:
        return ServerFailure(text('failure.server'), statusCode: code);
    }
  }

  /// Maps a transport-level [DioException].
  ///
  /// A `badResponse` is delegated to [ServerFailure.fromResponse] so the status
  /// code is honoured — the original mapped every one of them to the same
  /// generic message.
  factory ServerFailure.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return TimeoutFailure('failure.timeout'.tr());
      case DioExceptionType.cancel:
        return CancelledFailure('failure.cancelled'.tr());
      case DioExceptionType.connectionError:
        return _fromConnectionError(dioError);
      case DioExceptionType.badCertificate:
        // The handshake itself failed. That is never the user's network.
        return ServerUnreachableFailure('failure.server_unreachable'.tr());
      case DioExceptionType.badResponse:
        return ServerFailure.fromResponse(dioError.response);
      case DioExceptionType.unknown:
        if (dioError.error is SocketException) {
          return NetworkFailure('failure.no_internet'.tr());
        }
        return ServerFailure('failure.unexpected'.tr());
    }
  }

  /// Maps whatever a repository caught.
  ///
  /// When the error interceptor has already classified the failure it is
  /// attached to the exception, and that is returned unchanged. Every existing
  /// repository calls this, so none of them needed editing to start reporting
  /// typed failures.
  factory ServerFailure.fromCatchError(dynamic e) {
    if (e is DioException) {
      final Object? attached = e.error;
      if (attached is ServerFailure) return attached;
      return ServerFailure.fromDioError(e);
    }
    if (e is SocketException) {
      return _fromSocketException(e);
    }
    return ServerFailure('failure.unexpected'.tr());
  }

  /// Splits a connection error into "we could not reach the server" and
  /// "the server refused us".
  ///
  /// Dio reports a dead host and a dead network identically, and the original
  /// message asserted the second — so an API host that does not resolve reads
  /// as "No Internet Connection" on a phone with perfectly good internet, and
  /// sends whoever is debugging it to the wrong place entirely.
  static ServerFailure _fromConnectionError(DioException error) {
    final Object? cause = error.error;
    if (cause is SocketException) return _fromSocketException(cause);
    return NetworkFailure('failure.no_internet'.tr());
  }

  static ServerFailure _fromSocketException(SocketException e) {
    final String message = e.message.toLowerCase();
    final String os = (e.osError?.message ?? '').toLowerCase();

    // A refusal means something answered — the host exists and the port is
    // closed or the service is down. Nothing to do with connectivity.
    const List<String> refused = <String>[
      'connection refused',
      'connection reset',
      'connection timed out',
    ];
    for (final String needle in refused) {
      if (message.contains(needle) || os.contains(needle)) {
        return ServerUnreachableFailure('failure.server_unreachable'.tr());
      }
    }

    // Everything else — a failed host lookup, no route — is indistinguishable
    // between "the device is offline" and "the host does not exist", so the
    // message says what is certain: we could not reach it. It no longer
    // claims the device has no internet.
    return NetworkFailure('failure.no_internet'.tr());
  }

  /// Reads a non-2xx response.
  ///
  /// Defensive throughout: the body may be HTML, empty, or a list. The original
  /// indexes `data['errors']` and `data["message"]` directly, so an error page
  /// from a proxy crashes the handler that was supposed to report it.
  factory ServerFailure.fromResponse(Response<dynamic>? response) {
    final int? code = response?.statusCode;
    final dynamic data = response?.data;

    if (data is! Map) return ServerFailure.fromStatusCode(code);

    final Map<String, List<String>> errors = _readErrors(data['errors']);
    final String? message = data['message'] is String
        ? data['message'] as String
        : null;

    if (errors.isNotEmpty) {
      return ValidationFailure(
        message ?? 'failure.validation'.tr(),
        errors: errors,
      );
    }
    return ServerFailure.fromStatusCode(code, message);
  }

  /// Normalises the v2 `errors` object: field name to its messages.
  static Map<String, List<String>> _readErrors(dynamic raw) {
    if (raw is! Map) return const <String, List<String>>{};
    final Map<String, List<String>> mapped = <String, List<String>>{};
    raw.forEach((dynamic key, dynamic value) {
      if (key is! String) return;
      if (value is List) {
        mapped[key] = value.whereType<String>().toList();
      } else if (value is String) {
        mapped[key] = <String>[value];
      }
    });
    return mapped;
  }
}

/// 401 — the token is invalid or expired.
///
/// The only failure that ends the session.
class UnauthorizedFailure extends ServerFailure {
  UnauthorizedFailure(super.errMessage) : super(statusCode: 401);
}

/// 402 — the **venue's** platform licence is suspended or cancelled.
///
/// Not an authentication problem. It must never clear the token, never route
/// to sign in, and never cascade into a global locked state: the remedy is in
/// the web admin console and the user has done nothing wrong. A `past_due`
/// company is not suspended and keeps working.
class LicenceSuspendedFailure extends ServerFailure {
  LicenceSuspendedFailure(super.errMessage) : super(statusCode: 402);
}

/// 403 — authenticated, but not permitted. Explain; never sign out.
class ForbiddenFailure extends ServerFailure {
  ForbiddenFailure(super.errMessage) : super(statusCode: 403);
}

/// 404 — no such resource, or it is outside the caller's scope.
class NotFoundFailure extends ServerFailure {
  NotFoundFailure(super.errMessage) : super(statusCode: 404);
}

/// 422 — validation. [errors] maps a field name to its messages so a form can
/// attach each one to the right input instead of showing a banner.
class ValidationFailure extends ServerFailure {
  ValidationFailure(
    super.errMessage, {
    this.errors = const <String, List<String>>{},
  }) : super(statusCode: 422);

  final Map<String, List<String>> errors;

  /// The first message for [field], if the server rejected it.
  String? forField(String field) {
    final List<String>? messages = errors[field];
    return (messages == null || messages.isEmpty) ? null : messages.first;
  }
}

/// 429 — rate limited. [retryAfter] is the server's window when it sent one,
/// which the OTP screens surface directly.
class RateLimitedFailure extends ServerFailure {
  RateLimitedFailure(super.errMessage, {this.retryAfter})
    : super(statusCode: 429);

  final Duration? retryAfter;
}

/// The request never reached the server.
///
/// Covers both a device with no connectivity and a host that does not resolve
/// — the platform reports them identically, so the message says only what is
/// certain rather than blaming the user's connection.
class NetworkFailure extends ServerFailure {
  NetworkFailure(super.errMessage);
}

/// Something answered and refused, or the TLS handshake failed.
///
/// Definitely the server's end, so the message says so instead of sending the
/// user to check their wifi.
class ServerUnreachableFailure extends ServerFailure {
  ServerUnreachableFailure(super.errMessage);
}

/// The request timed out.
class TimeoutFailure extends ServerFailure {
  TimeoutFailure(super.errMessage);
}

/// The request was cancelled, usually because its owner was disposed.
class CancelledFailure extends ServerFailure {
  CancelledFailure(super.errMessage);
}
