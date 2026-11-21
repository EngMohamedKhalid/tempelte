import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../../local/cache/cache_helper.dart';
import '../../local/cache/cache_keys.dart';
import '../../local/notifications/local_notifications.dart';

/// Firebase Cloud Messaging.
///
/// This is the transport only: it acquires the token, listens on the three
/// delivery paths, and hands what arrives to whoever registered [onToken] and
/// [onTap]. Deciding what a push *means* — registering the device, choosing a
/// screen — belongs to `NotificationsCubit`, which is why nothing here imports
/// a feature.
class FirebaseNotifications {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// Called with the device token, on acquisition and on every refresh.
  ///
  /// FCM rotates tokens on reinstall, restore and clear-data, and a rotated
  /// token that is never re-registered is a phone that silently stops
  /// receiving anything.
  static Future<void> Function(String token)? onToken;

  /// Called with a tapped notification's `data` payload.
  static void Function(Map<String, dynamic> data)? onTap;

  /// A tap that launched the app from terminated, held until something is
  /// listening.
  ///
  /// `getInitialMessage()` resolves during `main()`, long before any screen or
  /// cubit exists — and before splash decides where the session belongs. The
  /// legacy drops it on the floor; here it waits for [takePendingTap].
  static Map<String, dynamic>? _pendingTap;

  /// Initialize Firebase Messaging
  static Future<void> initialize() async {
    try {
      // Request FCM Permissions
      await _handleNotificationPermissions();

      // Fetch FCM Token and save to local storage
      final token = await _fcm.getToken();
      if (token != null) {
        await CacheHelper.save(CacheKeys.fcmToken, token);
        await onToken?.call(token);
      }
      // Never logged. The legacy prints it, and a push token in a log is a
      // notification channel anyone reading that log can take over.
      log('FCM token ${token == null ? 'unavailable' : 'acquired'}');

      _fcm.onTokenRefresh.listen(_handleTokenRefresh);

      // Subscribe to default topic
      await subscribeToTopic('AllUsers');

      // Handle initial notification when app launches
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) _handleNotificationTap(initialMessage);

      // Set up notification listeners
      FirebaseMessaging.onMessage.listen(_handleNotificationForeground);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
      FirebaseMessaging.onBackgroundMessage(_handleNotificationBackground);
    } catch (e) {
      log('Error initializing Firebase Messaging: $e');
    }
  }

  /// Request notification permissions
  static Future<void> _handleNotificationPermissions() async {
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      carPlay: false,
      provisional: false,
      announcement: false,
      criticalAlert: false,
    );
  }

  /// A rotated token is cached and re-registered.
  static Future<void> _handleTokenRefresh(String token) async {
    await CacheHelper.save(CacheKeys.fcmToken, token);
    await onToken?.call(token);
  }

  /// Handle notification tap
  static Future<void> _handleNotificationTap(RemoteMessage msg) async {
    deliverTap(msg.data);
  }

  /// Hands a payload to [onTap], or holds it until something is listening.
  static void deliverTap(Map<String, dynamic> data) {
    final void Function(Map<String, dynamic>)? handler = onTap;
    if (handler == null) {
      _pendingTap = data;
      return;
    }
    handler(data);
  }

  /// Takes the tap that launched the app, if there was one. Returns it once.
  static Map<String, dynamic>? takePendingTap() {
    final Map<String, dynamic>? pending = _pendingTap;
    _pendingTap = null;
    return pending;
  }

  /// Handle notification when app is in the foreground
  static Future<void> _handleNotificationForeground(RemoteMessage msg) async {
    await LocalNotificationService.displayNotification(msg);
  }

  /// Handle notification when app is in the background
  ///
  /// Runs in its own isolate with no app state, so it does nothing: a
  /// notification message is drawn by the system, and anything this handler
  /// changed would be invisible to the running app anyway.
  @pragma('vm:entry-point')
  static Future<void> _handleNotificationBackground(RemoteMessage msg) async {}

  /// Subscribe to a topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _fcm.subscribeToTopic(topic);
      log('Subscribed to topic: $topic');
    } catch (e) {
      log('Failed to subscribe to topic $topic: $e');
    }
  }

  /// Unsubscribe from a topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fcm.unsubscribeFromTopic(topic);
      log('Unsubscribed from topic: $topic');
    } catch (e) {
      log('Failed to unsubscribe from topic $topic: $e');
    }
  }
}
