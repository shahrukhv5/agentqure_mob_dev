// import 'dart:io';
//
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter/material.dart';
//
// class NotificationService {
//   static final NotificationService _instance = NotificationService._internal();
//   factory NotificationService() => _instance;
//   NotificationService._internal();
//
//   static final FlutterLocalNotificationsPlugin _notifications =
//       FlutterLocalNotificationsPlugin();
//
//   Future<void> initialize() async {
//     const AndroidInitializationSettings androidSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     const DarwinInitializationSettings iosSettings =
//         DarwinInitializationSettings(
//           requestAlertPermission: true,
//           requestBadgePermission: true,
//           requestSoundPermission: true,
//         );
//
//     const InitializationSettings settings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );
//
//     await _notifications.initialize(settings);
//     if (Platform.isAndroid) {
//       await _notifications
//           .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin
//           >()
//           ?.requestNotificationsPermission();
//     } else {
//       _notifications
//           .resolvePlatformSpecificImplementation<
//             IOSFlutterLocalNotificationsPlugin
//           >()
//           ?.requestPermissions();
//     }
//   }
//
//   Future<void> showNotification({
//     required int id,
//     required String title,
//     required String body,
//     String? payload,
//   }) async {
//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//           'main_channel',
//           'Main Channel',
//           channelDescription: 'Main notifications channel',
//           importance: Importance.max,
//           priority: Priority.high,
//           playSound: true,
//         );
//
//     const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );
//
//     const NotificationDetails details = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );
//
//     await _notifications.show(id, title, body, details, payload: payload);
//   }
//
//   Future<void> showWelcomeNotification(double pointBalance) async {
//     await showNotification(
//       id: 1,
//       title: 'Welcome to Agentqure!',
//       body: 'You have ₹${pointBalance.toStringAsFixed(0)} points in your wallet. '
//           'Start earning more rewards by referring friends!',
//       // body:
//       //     'You have ₹${pointBalance.toStringAsFixed(0)} points in your wallet. Start earning more rewards!',
//     );
//   }
//
//   Future<void> showOrderNotification(String orderId, double amount) async {
//     await showNotification(
//       id: 2,
//       title: 'Booking Confirmed Successfully!',
//       body: 'Your booking for ₹${amount.toStringAsFixed(0)} '
//           'has been confirmed. You will receive updates about your booking status. '
//           'Thank you for choosing Agentqure!',
//       // body:
//       //     'Your booking for ₹${amount.toStringAsFixed(0)} has been confirmed.',
//     );
//   }
//
// }
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@drawable/ic_stat_white_logo');

    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
    if (Platform.isAndroid) {
      await _notifications
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
      >()
          ?.requestNotificationsPermission();
    } else {
      _notifications
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
      >()
          ?.requestPermissions();
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'main_channel',
      'Main Channel',
      channelDescription: 'Main notifications channel',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      styleInformation: BigTextStyleInformation(
        body,
        htmlFormatBigText: true,
        contentTitle: title,
        htmlFormatContentTitle: true,
      ),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  Future<void> showWelcomeNotification(double pointBalance) async {
    await showNotification(
      id: 1,
      title: 'Welcome to AgentQure!',
      body: 'You have ₹${pointBalance.toStringAsFixed(0)} points in your wallet. '
          'Start earning more rewards by referring friends!',
    );
  }

  Future<void> showOrderNotification(String orderId, double amount) async {
    await showNotification(
      id: 2,
      title: 'Booking Confirmed Successfully!',
      body: 'Your booking for ₹${amount.toStringAsFixed(0)} '
          'has been confirmed. You will receive updates about your booking status. '
          'Thank you for choosing AgentQure!',
    );
  }
}