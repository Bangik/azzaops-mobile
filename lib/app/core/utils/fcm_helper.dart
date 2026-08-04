import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../../../firebase_options.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/core/utils/storage_helper.dart';
import '../../../app/data/providers/api_provider.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if not already initialized (required in background isolate)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Handling background message: ${message.messageId}');
}

class FcmHelper {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'azzaops_alerts',
    'AzzaOps Alerts',
    description: 'Channel for AzzaOps emergency and job alerts.',
    importance: Importance.max,
    playSound: true,
  );

  static Future<void> init() async {
    try {
      // 1. Initialize Firebase
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

      // 2. Set background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 3. Request permissions (Android 13+ and iOS)
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      // 4. Set up Foreground notification presentation
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 5. Initialize Local Notifications for Foreground display
      const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
      
      await _localNotifications.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          if (details.payload != null) {
            try {
              final data = jsonDecode(details.payload!) as Map<String, dynamic>;
              _handlePayload(data);
            } catch (_) {}
          }
        },
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      // 6. Listen to foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = message.notification;
        final android = message.notification?.android;
        final data = message.data;

        if (notification != null && !kIsWeb) {
          _localNotifications.show(
            id: notification.hashCode,
            title: notification.title,
            body: notification.body,
            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                _channel.id,
                _channel.name,
                channelDescription: _channel.description,
                icon: android?.smallIcon ?? '@mipmap/ic_launcher',
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
              ),
            ),
            payload: jsonEncode(data),
          );
        }
      });

      // 7. Listen to notification click when app is in background (but not terminated)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handlePayload(message.data);
      });

      // 8. Check if app was opened from terminated state via a notification
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handlePayload(initialMessage.data);
      }

      // 9. Fetch and upload FCM token if user is logged in
      final token = await _messaging.getToken();
      if (token != null) {
        debugPrint('FCM TOKEN: $token');
        // Save locally first
        await _saveLocalFcmToken(token);
        // Upload if logged in
        await uploadFcmToken(token);
      }

      // 10. Listen to token refresh
      _messaging.onTokenRefresh.listen((token) async {
        await _saveLocalFcmToken(token);
        await uploadFcmToken(token);
      });

    } catch (e) {
      debugPrint('Error initializing FCM: $e');
    }
  }

  static Future<void> _saveLocalFcmToken(String token) async {
    // We can save in GetStorage for caching
    // Let's add support in storage helper or directly in box
  }

  static Future<void> uploadFcmToken(String token) async {
    final userToken = StorageHelper.getToken();
    if (userToken == null) return; // User not logged in yet

    try {
      final apiProvider = Get.put(ApiProvider());
      final response = await apiProvider.put('/profile/fcm-token', {
        'fcm_token': token,
      });
      if (response.statusCode == 200) {
        debugPrint('FCM Token successfully registered on backend');
      }
    } catch (e) {
      debugPrint('Failed to upload FCM Token to backend: $e');
    }
  }

  static void _handlePayload(Map<String, dynamic> data) {
    if (data['work_order_id'] != null) {
      final woId = int.tryParse(data['work_order_id'].toString());
      if (woId != null) {
        Get.toNamed(AppRoutes.WORK_ORDER_DETAIL, arguments: woId);
      }
    }
  }
}
