/// Body for requesting a password-reset code.
class ForgetParam {
  ForgetParam({required this.phone});

  /// Full international number.
  final String phone;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['phone'] = phone;
    map['purpose'] = 'reset';
    return map;
  }
}
