import '../../../../../core/shared/models/device_param.dart';

/// Body for `POST auth/register`.
///
/// **Verify first, then register.** The endpoint requires a
/// `verification_token` — the proof that the OTP sent to the number was
/// entered correctly — and takes no phone number of its own: the token carries
/// it. Confirmed against the live API, where an empty body answers with
/// `verification_token`, `name` and `password` required.
///
/// This replaces the ordinary registration first built here, which posted the
/// form and confirmed the number afterwards. That is what the legacy app does,
/// and the v2 server rejects it: the request 422s every time.
class SignUpParam {
  SignUpParam({
    required this.verificationToken,
    required this.name,
    required this.password,
    this.email,
  });

  /// Minted by `auth/otp/verify` for the number being registered.
  final String verificationToken;

  final String name;

  /// At least 8 characters — the server's rule, checked before it is sent.
  final String password;

  /// Optional, and validated as an address when given.
  final String? email;

  Future<Map<String, dynamic>> toJson() async {
    final map = <String, dynamic>{};
    map['verification_token'] = verificationToken;
    map['name'] = name;
    map['password'] = password;
    // Sent only when filled: an empty string fails the server's email rule,
    // so an optional field left blank would block the registration.
    if (email != null && email!.trim().isNotEmpty) map['email'] = email!.trim();

    final DeviceParam? device = await DeviceParam.current();
    if (device != null) map['device'] = device.toJson();
    return map;
  }
}
