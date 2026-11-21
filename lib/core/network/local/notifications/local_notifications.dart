import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../remote/firebase/firebase_messaging.dart';

class LocalNotificationService {
  static final _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    try {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (Platform.isAndroid && androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
      }
      if (Platform.isIOS) {
        await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
        final settings = await FirebaseMessaging.instance.requestPermission();
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          // The value is never logged — a push token in a log is a
          // notification channel anyone reading that log can take over. The
          // legacy prints it twice.
          final String? apnsToken = await FirebaseMessaging.instance
              .getAPNSToken();
          log(
            apnsToken == null
                ? "APNS token not available yet."
                : "APNS token acquired.",
          );
        } else {
          log("Notification permission not granted");
        }
      }
      const initialSettings = InitializationSettings(
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      );
      await _notificationsPlugin.initialize(
        settings: initialSettings,
        onDidReceiveNotificationResponse: receiveNotification,
        onDidReceiveBackgroundNotificationResponse: receiveNotification,
      );
      log("Notification service initialized successfully.");
    } catch (e) {
      log("Error initializing notification service: $e");
    }
  }

  static String convertJsonFormat(String? jsonStr) {
    return jsonStr?.replaceAllMapped(RegExp(r'(\w+)(\s*:\s*)(\w+)'), (match) {
          String key = match.group(1)!;
          String colon = match.group(2)!;
          String value = match.group(3)!;
          bool isNumeric = double.tryParse(value) != null;
          bool isBoolean = value == 'true' || value == 'false';
          if (!isNumeric && !isBoolean) value = '"$value"';
          return '"$key"$colon$value';
        }) ??
        '{}';
  }

  /// Hands a tapped local notification to the same place a tapped push goes.
  ///
  /// The legacy decides here, in the notification service, comparing
  /// `data["type"]` against two literals and pushing a screen — so the rule
  /// for what a notification opens lives in two places and they disagree.
  /// This one forwards; `NotificationsCubit` decides.
  static void navigateNotification(Map<String, dynamic> data) {
    FirebaseNotifications.deliverTap(data);
  }

  static void receiveNotification(NotificationResponse response) {
    if (response.payload != null) {
      Map<String, dynamic> data = jsonDecode(response.payload!);
      navigateNotification(data);
    }
  }

  static Future<void> displayNotification(RemoteMessage message) async {
    try {
      final int id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const notificationDetails = NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          // sound: 'default',
        ),
        android: AndroidNotificationDetails(
          'PushNotificationApp',
          'PushNotificationAppChannel',
          priority: Priority.high,
          importance: Importance.max,
          playSound: true,
          // sound: RawResourceAndroidNotificationSound('default',),
        ),
      );

      await _notificationsPlugin.show(
        id: id,
        title: message.notification!.title ?? '',
        body: message.notification!.body ?? '',
        notificationDetails: notificationDetails,
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      log('Error creating and displaying notification: $e');
    }
  }

  static void displayPopNotification(NotificationModel notification) {
    displayNotification(
      RemoteMessage(
        notification: RemoteNotification(
          title: notification.title,
          body: notification.message,
          android: AndroidNotification(
            imageUrl: notification.notificationImage,
          ),
          apple: AppleNotification(imageUrl: notification.notificationImage),
        ),
      ),
    );
  }
}

class NotificationModel {
  String? sId;
  String? type;
  String? status;
  String? priority;
  String? readAt;
  String? createdAt;
  String? updatedAt;
  String? notificationImage;
  String? title;
  String? message;

  NotificationModel({
    this.sId,
    this.type,
    this.status,
    this.priority,
    this.readAt,
    this.createdAt,
    this.updatedAt,
    this.notificationImage,
    this.title,
    this.message,
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    type = json['type'];
    title = json['title'];
    message = json['message'];
    priority = json['priority'];
    notificationImage = json['notificationImage'];
    status = json['status'];
    readAt = json['readAt'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  static List<NotificationModel> formListJson(List data) {
    return List.from(data.map((e) => NotificationModel.fromJson(e)).toList());
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final NotificationModel otherCategory = other as NotificationModel;
    return sId == otherCategory.sId;
  }

  @override
  int get hashCode => sId.hashCode;
}
