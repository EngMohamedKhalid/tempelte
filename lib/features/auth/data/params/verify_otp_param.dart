import '../../../../../core/shared/models/device_param.dart';

/// What an OTP is being requested or checked for.
enum OtpPurpose { login, register, reset }

/// Body for `POST auth/otp` and `POST auth/otp/verify`.
class VerifyOtpParam {
  VerifyOtpParam({
    required this.phone,
    required this.purpose,
    this.code,
  });

  /// Full international number.
  final String phone;

  /// Why the code was sent. The server rate-limits and expires per purpose, so
  /// a registration code cannot be replayed against a password reset.
  final OtpPurpose purpose;

  /// Null when requesting a code, set when checking one.
  final String? code;

  Future<Map<String, dynamic>> toJson() async {
    final map = <String, dynamic>{};
    map['phone'] = phone;
    map['purpose'] = purpose.name;
    if (code != null) map['code'] = code;

    final DeviceParam? device = await DeviceParam.current();
    if (device != null) map['device'] = device.toJson();
    return map;
  }
}
