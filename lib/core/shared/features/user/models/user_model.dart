import '../../../../helper/app_locals.dart';

/// The signed-in account, as `GET me` returns it.
///
/// **Copied from the legacy core, then extended on 2026-09-23.** The four
/// fields at the bottom — `nameEn`, `isStaff`, `locale`, `isActive` — are in
/// every `me` response the v2 API sends and were simply never read. `PATCH me`
/// writes three of them, and `isStaff` decides whether the delete-account row
/// is offered at all, so they are parsed now.
///
/// `provider` and `carCount` are kept because the legacy core declares them.
/// **`car_count` is not a field v2 sends** — the car count comes from the
/// length of `GET /cars` — so it parses as null and nothing should rely on it.
class UserModel {
  UserModel({
    this.name,
    this.email,
    this.phone,
    this.role,
    this.provider,
    this.carCount,
    this.nameEn,
    this.isStaff,
    this.locale,
    this.isActive,
  });

  UserModel.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    role = json['role'];
    provider = json['provider'];
    carCount = json['car_count'];
    nameEn = json['name_en'];
    isStaff = json['is_staff'];
    locale = json['locale'];
    isActive = json['is_active'];
  }
  int? id;
  String? name;
  String? email;
  String? phone;
  String? role;
  String? provider;
  int? carCount;

  /// The account's name in English, where one was given. Nullable on purpose:
  /// the server accepts `null` to clear it.
  String? nameEn;

  /// Whether this account is a driver or a supervisor.
  ///
  /// The server refuses `DELETE me` for staff — their company manages those
  /// accounts from the console — so the row is not offered to them at all.
  /// Null is treated as "not staff" nowhere: callers should read it through
  /// [isStaffAccount], which falls back to the role.
  bool? isStaff;

  /// `ar` or `en`. Writable through `PATCH me`.
  String? locale;

  /// Whether the account is enabled.
  bool? isActive;

  /// Staff-ness, with the role as a fallback.
  ///
  /// An older server, or a cached session written before this field was read,
  /// carries no `is_staff` — and answering "not staff" there would offer a
  /// supervisor a delete button the server is going to refuse.
  bool get isStaffAccount =>
      isStaff ?? (role == 'driver' || role == 'supervisor');

  /// The name to show, in the reader's language.
  ///
  /// An English reader gets [nameEn]; every other reader (ar, ur, bn) gets
  /// [name] — the same rule as `ParkingModel.displayName`. Unlike a car park,
  /// this is the reader's own account, so each side falls back to the other
  /// rather than showing a blank: a name given in only one language is still
  /// their name. Empty when the account has neither.
  ///
  /// The locale is read live, so a model parsed before a language change
  /// still answers in the new language.
  String get displayName {
    final String own = name?.trim() ?? '';
    final String english = nameEn?.trim() ?? '';
    if (AppLocales.currentLocale.languageCode == 'en') {
      return english.isEmpty ? own : english;
    }
    return own.isEmpty ? english : own;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['email'] = email;
    map['phone'] = phone;
    map['role'] = role;
    map['provider'] = provider;
    map['car_count'] = carCount;
    map['name_en'] = nameEn;
    map['is_staff'] = isStaff;
    map['locale'] = locale;
    map['is_active'] = isActive;
    return map;
  }
}
