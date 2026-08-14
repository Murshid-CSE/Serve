import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Service for displaying local notifications when FCM messages arrive
/// while the app is in the foreground.
class LocalNotificationService {
  LocalNotificationService._();
  static final instance = LocalNotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Android notification channel for Community Care Hub
  static const _androidChannel = AndroidNotificationChannel(
    'community_care_hub_channel',
    'Community Care Hub',
    description: 'Notifications for food, blood, volunteer and emergency alerts',
    importance: Importance.high,
  );

  /// Initialize the local notification plugin and create Android channel
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create the Android notification channel
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_androidChannel);

    _initialized = true;
  }

  /// Show a local notification from a foreground FCM message
  Future<void> showFromFCM(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _plugin.show(
      notification.hashCode,
      notification.title ?? 'Community Care Hub',
      notification.body ?? '',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: message.data['type'] != null
          ? '${message.data['type']}:${message.data['id'] ?? ''}'
          : null,
    );
  }

  /// Handle notification tap (foreground local notifications)
  static void _onNotificationTap(NotificationResponse response) {
    // Navigation is handled by the NotificationManager's tap handler
    // Local notifications from foreground FCM carry the same payload
    // The app is already open, so deep-linking is optional here
  }
}
