import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();

  /// Initialize notifications
  static Future<void> initialize() async {
    try {
      // Request permission
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      
      debugPrint('Notification permission: ${settings.authorizationStatus}');

    
      
     const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
const iosSettings = DarwinInitializationSettings();
const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
await _localNotifications.initialize(initSettings);

      // Get FCM token
      final token = await _messaging.getToken();
      debugPrint('FCM Token: $token');
      
      // Save token to your backend if needed
      await _saveTokenToBackend(token);

    } catch (e) {
      debugPrint('Notification init error: $e');
    }
  }

  /// Save token to your backend (simplified)
  static Future<void> _saveTokenToBackend(String? token) async {
    if (token == null) return;
    
    debugPrint('📱 FCM Token for backend: $token');
    // TODO: Send token to your server
    // Example: await http.post('your-api/token', body: {'token': token});
  }

  /// Setup message handlers
  static void setupMessageHandlers() {
    // When app is in FOREGROUND
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📱 Foreground message: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // When app is in BACKGROUND
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📱 Background message opened: ${message.notification?.title}');
      _handleMessageTap(message);
    });

    // When app is TERMINATED
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        debugPrint('📱 Terminated message: ${message.notification?.title}');
        _handleMessageTap(message);
      }
    });
  }

  /// Show local notification
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'plant_channel',
      'Plant Notifications',
      channelDescription: 'Plant care reminders and updates',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const iosDetails = DarwinNotificationDetails();
    
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? 'Plant Reminder',
      message.notification?.body ?? '',
      const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: message.data['screen'] ?? '/',
    );
  }

  /// Handle notification tap
  static void _handleMessageTap(RemoteMessage message) {
    final screen = message.data['screen'];
    if (screen != null) {
      debugPrint('Navigate to: $screen');
      // Use NavigationService or navigatorKey to navigate
    }
  }

  /// Subscribe to topics for targeted notifications
  static Future<void> subscribeToTopics() async {
    await _messaging.subscribeToTopic('plant_care_tips');
    debugPrint('✅ Subscribed to plant_care_tips');
  }

  /// Unsubscribe from topics
  static Future<void> unsubscribeFromTopics() async {
    await _messaging.unsubscribeFromTopic('plant_care_tips');
    debugPrint('❌ Unsubscribed from plant_care_tips');
  }
}