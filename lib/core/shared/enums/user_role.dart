import 'package:easy_localization/easy_localization.dart';

/// The roles `GET /me` can return.
///
/// Exactly three. The platform defines more — owner, accountant, admin,
/// super_admin — but those have permission on the web console only and the
/// API never emits them here, so the app has no branch for them.
///
/// **Porting note.** v1 called the customer role `user`; v2 calls it
/// `customer`. The legacy code compares `role == "user"` in eight places, so
/// any screen ported without this enum will silently treat customers as
/// something else. Parse once, here, and compare the enum everywhere after.
enum UserRoleEnum {
  customer('customer'),
  driver('driver'),
  supervisor('supervisor');

  const UserRoleEnum(this.key);

  /// The value the API sends.
  final String key;

  /// Translated label.
  String get title => 'roles.$key'.tr();

  /// Works the staff surfaces: the board, walk-ins, shifts.
  bool get isStaff =>
      this == UserRoleEnum.driver || this == UserRoleEnum.supervisor;

  /// Only a supervisor may assign a driver to a booking.
  bool get canAssignDriver => this == UserRoleEnum.supervisor;
}

/// Parses the API value.
///
/// Also accepts the v1 spelling `user` so a cached session written by the old
/// app resolves rather than falling through. Returns null for anything else —
/// including the console-only roles — so the caller decides what an
/// unrecognised role means instead of guessing a shell.
UserRoleEnum? getUserRoleEnum(String? key) {
  switch (key) {
    case 'customer':
    case 'user':
      return UserRoleEnum.customer;
    case 'driver':
      return UserRoleEnum.driver;
    case 'supervisor':
      return UserRoleEnum.supervisor;
    default:
      return null;
  }
}
