import '../../../../../core/shared/models/device_param.dart';

/// Body for `POST auth/login`.
class SignInParam {
  SignInParam({required this.phone, required this.password});

  /// Full international number, e.g. `+966501234567`.
  final String phone;

  final String password;

  /// The legacy sends the phone number in a field called `email`, and prints
  /// the push token to the console on the way. Both are gone.
  Future<Map<String, dynamic>> toJson() async {
    final map = <String, dynamic>{};
    map['phone'] = phone;
    map['password'] = password;

    final DeviceParam? device = await DeviceParam.current();
    if (device != null) map['device'] = device.toJson();
    return map;
  }
}
