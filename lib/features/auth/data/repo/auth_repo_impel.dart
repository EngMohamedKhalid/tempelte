import 'package:dartz/dartz.dart';

import '../../../../../core/network/errors/failure.dart';
import '../../../../../core/network/local/cache/cache_helper.dart';
import '../../../../../core/network/local/cache/cache_keys.dart';
import '../../../../../core/network/remote/apis/dio_helper.dart';
import '../../../../../core/network/remote/end_points.dart';
import '../../../../../core/shared/features/user/models/user_model.dart';
import '../../../notifications/data/repo/notifications_repo_impel.dart';
import '../params/forget_param.dart';
import '../params/reset_param.dart';
import '../params/sign_in_param.dart';
import '../params/sign_up_param.dart';
import '../params/verify_otp_param.dart';
import 'auth_repo.dart';

/// Talks to the auth endpoints.
///
/// Every method has the same shape: call, read the body, or hand whatever was
/// thrown to `ServerFailure.fromCatchError`, which returns the typed failure
/// the error interceptor already classified. No method inspects a status code
/// — `validateStatus` accepts only 2xx, so a non-2xx never arrives here as a
/// response.
class AuthRepoImpel implements AuthRepo {
  @override
  Future<Either<Failure, UserModel>> signIn(SignInParam param) async {
    try {
      final response = await DioHelper.post(
        url: LOGIN,
        data: await param.toJson(),
      );
      return right(await _storeSession(response.data));
    } catch (e) {
      return left(ServerFailure.fromCatchError(e));
    }
  }

  @override
  Future<Either<Failure, String>> signUp(SignUpParam param) async {
    try {
      final response = await DioHelper.post(
        url: REGISTER,
        data: await param.toJson(),
      );
      // Registration completes an identity the server has already verified, so
      // it may hand back a session rather than making the new user sign in
      // again. Stored when it does; harmless when it does not.
      await _storeSession(response.data);
      return right('success');
    } catch (e) {
      return left(ServerFailure.fromCatchError(e));
    }
  }

  @override
  Future<Either<Failure, String>> verifyCode(VerifyOtpParam param) async {
    try {
      final response = await DioHelper.post(
        url: VERIFY_OTP,
        data: await param.toJson(),
      );
      final data = response.data;

      // A reset flow needs the verification token carried to the next screen.
      // A registration flow gets a session instead, when the server issues one.
      final Map<String, dynamic> body = data is Map<String, dynamic>
          ? (data['data'] is Map<String, dynamic>
                ? data['data'] as Map<String, dynamic>
                : data)
          : <String, dynamic>{};

      if (body['token'] is String) await _storeSession(data);

      return right(body['verification_token'] as String? ?? '');
    } catch (e) {
      return left(ServerFailure.fromCatchError(e));
    }
  }

  @override
  Future<Either<Failure, String>> resendCode(VerifyOtpParam param) async {
    try {
      await DioHelper.post(url: REQUEST_OTP, data: await param.toJson());
      return right('success');
    } catch (e) {
      return left(ServerFailure.fromCatchError(e));
    }
  }

  @override
  Future<Either<Failure, String>> forgetPassword(ForgetParam param) async {
    try {
      await DioHelper.post(url: REQUEST_OTP, data: param.toJson());
      return right('success');
    } catch (e) {
      return left(ServerFailure.fromCatchError(e));
    }
  }

  @override
  Future<Either<Failure, String>> resetPassword(ResetParam param) async {
    try {
      await DioHelper.post(url: RESET_PASSWORD, data: param.toJson());
      return right('success');
    } catch (e) {
      return left(ServerFailure.fromCatchError(e));
    }
  }

  @override
  Future<Either<Failure, UserModel>> getUser() async {
    try {
      final response = await DioHelper.get(url: MY_INFO);
      final UserModel user = UserModel.fromJson(_unwrap(response.data));
      // Kept for the push handlers, which run without a BuildContext and
      // before any screen exists. Refreshed here so it can never go stale
      // behind a role change.
      if (user.role != null) await CacheHelper.save(CacheKeys.role, user.role!);
      return right(user);
    } catch (e) {
      return left(ServerFailure.fromCatchError(e));
    }
  }

  @override
  Future<Either<Failure, String>> logout() async {
    try {
      // Before the token is revoked, not after: `DELETE /devices` needs the
      // session it is detaching from. A phone signed out with its token still
      // registered keeps receiving the account's notifications.
      await _detachDevice();
      await DioHelper.post(url: LOGOUT);
      return right('success');
    } catch (e) {
      return left(ServerFailure.fromCatchError(e));
    } finally {
      // The local session goes regardless. A server that will not accept the
      // logout is no reason to leave someone signed in on the device.
      await CacheHelper.remove(CacheKeys.token);
    }
  }

  /// Removes this device's push token from the account being signed out.
  ///
  /// Never blocks the sign-out: a failure here leaves a stale registration,
  /// which is worth reporting but not worth trapping someone in a session.
  Future<void> _detachDevice() async {
    final String? fcmToken = CacheHelper.get(CacheKeys.fcmToken) as String?;
    if (fcmToken == null || fcmToken.isEmpty) return;
    await NotificationsRepoImpel().unregisterDevice(fcmToken);
  }

  /// Persists the token from a sign-in style response and returns the user.
  Future<UserModel> _storeSession(dynamic data) async {
    final Map<String, dynamic> body = _unwrap(data);
    final String? token = body['token'] as String?;
    if (token != null && token.isNotEmpty) {
      await CacheHelper.save(CacheKeys.token, token);
    }
    final dynamic user = body['user'] ?? body;
    return UserModel.fromJson(user);
  }

  /// Unwraps the `{data: ...}` envelope every v2 response uses.
  Map<String, dynamic> _unwrap(dynamic data) {
    if (data is! Map) return <String, dynamic>{};
    final dynamic inner = data['data'];
    if (inner is Map<String, dynamic>) return inner;
    return Map<String, dynamic>.from(data);
  }
}
