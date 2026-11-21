import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

import '../../network/local/cache/cache_helper.dart';
import '../../network/local/cache/cache_keys.dart';

/// The device a token is being issued to.
///
/// Sent as a nested object on every token-issuing call, and as the flat body
/// of `POST /devices`. It lives in `core` because two features need it —
/// auth issues tokens, notifications registers the device — and two features
/// needing one model is how the legacy ended up with two `CarModel`s.
///
/// Sent as a nested object on every token-issuing call. The legacy app sends a
/// bare `device_token` string instead, and the server keys the push token on
/// the account rather than the device — so signing in on a second phone steals
/// the first one's notifications.
class DeviceParam {
  DeviceParam({
    required this.fcmToken,
    required this.platform,
    required this.appVersion,
  });

  /// Reads what it can from the device. Returns null when there is no push
  /// token yet, which is the normal state until F13 registers one.
  static Future<DeviceParam?> current() async {
    final String? token = CacheHelper.get(CacheKeys.fcmToken) as String?;
    if (token == null || token.isEmpty) return null;

    String version = '';
    try {
      version = (await PackageInfo.fromPlatform()).version;
    } catch (_) {
      // Not worth failing a sign-in over.
    }

    return DeviceParam(
      fcmToken: token,
      platform: Platform.isIOS ? 'ios' : 'android',
      appVersion: version,
    );
  }

  final String fcmToken;
  final String platform;
  final String appVersion;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['fcm_token'] = fcmToken;
    map['platform'] = platform;
    if (appVersion.isNotEmpty) map['app_version'] = appVersion;
    return map;
  }
}
