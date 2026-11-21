/// Body for the password-reset call.
///
/// Sends the verification token when OTP verification returned one, and falls
/// back to the phone number when it did not — which is how the legacy endpoint
/// works.
///
/// The token is preferred because the legacy call takes a phone number and a
/// new password with **no proof the caller owns the number**: anyone who knows
/// it can reset the account. Keeping both means the flow works against either
/// server, and tightens automatically once the token is available.
class ResetParam {
  ResetParam({
    required this.password,
    required this.passwordConfirmation,
    this.verificationToken,
    this.phone,
  }) : assert(
         verificationToken != null || phone != null,
         'a reset needs either a verification token or a phone number',
       );

  /// Single-use, short-lived, issued by OTP verification.
  final String? verificationToken;

  /// Full international number. Used only when there is no token.
  final String? phone;

  final String password;
  final String passwordConfirmation;

  /// Whether this reset can prove the caller owns the number.
  bool get isProven =>
      verificationToken != null && verificationToken!.isNotEmpty;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    if (isProven) {
      map['verification_token'] = verificationToken;
      map['password'] = password;
      map['password_confirmation'] = passwordConfirmation;
      return map;
    }

    // The legacy shape.
    map['phone'] = phone;
    map['new_password'] = password;
    map['new_password_confirmation'] = passwordConfirmation;
    return map;
  }
}
