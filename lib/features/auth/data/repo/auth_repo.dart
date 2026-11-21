import 'package:dartz/dartz.dart';

import '../../../../../core/network/errors/failure.dart';
import '../../../../../core/shared/features/user/models/user_model.dart';
import '../params/forget_param.dart';
import '../params/reset_param.dart';
import '../params/sign_in_param.dart';
import '../params/sign_up_param.dart';
import '../params/verify_otp_param.dart';

/// Authentication data source.
abstract class AuthRepo {
  /// Signs in with a phone number and password.
  Future<Either<Failure, UserModel>> signIn(SignInParam param);

  /// Registers an account. The phone number is confirmed afterwards, by OTP.
  Future<Either<Failure, String>> signUp(SignUpParam param);

  /// Checks an OTP. Returns the single-use verification token when the code
  /// was sent for a password reset; an empty string otherwise.
  Future<Either<Failure, String>> verifyCode(VerifyOtpParam param);

  /// Sends a fresh OTP.
  Future<Either<Failure, String>> resendCode(VerifyOtpParam param);

  /// Starts a password reset by sending a code to [ForgetParam.phone].
  Future<Either<Failure, String>> forgetPassword(ForgetParam param);

  /// Sets a new password, proving ownership with the verification token.
  Future<Either<Failure, String>> resetPassword(ResetParam param);

  /// The signed-in user.
  Future<Either<Failure, UserModel>> getUser();

  /// Revokes the current token.
  Future<Either<Failure, String>> logout();
}
