import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_care_hub/features/notifications/domain/entities/app_notification_entity.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:community_care_hub/core/constants/firebase_constants.dart';
import 'package:community_care_hub/navigation/app_router.dart';
import 'package:community_care_hub/navigation/app_routes.dart';
import 'package:community_care_hub/core/services/local_notification_service.dart';

// Firebase Messaging Provider
final firebaseMessagingProvider = Provider<FirebaseMessaging>((ref) {
  return FirebaseMessaging.instance;
});

// Notifications List stream provider from Firestore
final notificationsListProvider = StreamProvider<List<AppNotificationEntity>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final user = userAsync.value;

  if (user == null) {
    return Stream.value([]);
  }

  return FirebaseFirestore.instance
      .collection(FirebaseConstants.usersCollection)
      .doc(user.uid)
      .collection(FirebaseConstants.notificationsCollection)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => AppNotificationEntity.fromMap({
              'id': doc.id,
              ...doc.data(),
            }))
        .toList();
  });
});

// Notification manager notifier containing subscription mechanics
final notificationManagerProvider = Provider<NotificationManager>((ref) {
  final manager = NotificationManager(ref);
  ref.onDispose(() {
    manager.dispose();
  });
  return manager;
});

class NotificationManager {
  NotificationManager(this._ref);
  final Ref _ref;

  bool _initialized = false;
  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _tapSubscription;

  /// Initializes messaging and requests permission
  Future<void> initializeNotifications() async {
    if (_initialized) return;
    _initialized = true;

    final messaging = _ref.read(firebaseMessagingProvider);

    // Request permissions
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle token updating in database
    final token = await messaging.getToken();
    if (token != null) {
      await _updateUserFcmToken(token);
    }

    // Monitor token updates
    _tokenSubscription = messaging.onTokenRefresh.listen((newToken) {
      _updateUserFcmToken(newToken);
    });

    // 1. Foreground message handler — show as local notification
    _foregroundSubscription = FirebaseMessaging.onMessage.listen((message) {
      LocalNotificationService.instance.showFromFCM(message);
    });

    // 2. Handle app opened from background via notification tap
    _tapSubscription = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationNavigation(message);
    });

    // 3. Handle cold start from terminated state via notification tap
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationNavigation(initialMessage);
    }
  }

  void _handleNotificationNavigation(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];
    final id = data['id'];

    final router = _ref.read(routerProvider);

    if (type != null && id != null) {
      final String route = switch (type) {
        'food' => AppRoutes.foodDetail.replaceAll(':id', id),
        'blood' => AppRoutes.bloodRequestDetail.replaceAll(':id', id),
        'volunteer' => AppRoutes.taskDetail.replaceAll(':id', id),
        'emergency' => AppRoutes.emergencyDetail.replaceAll(':id', id),
        _ => AppRoutes.notifications,
      };
      router.push(route);
    } else {
      router.push(AppRoutes.notifications);
    }
  }

  /// Subscribe to FCM topics depending on role and settings
  Future<void> syncTopicSubscriptions() async {
    final user = _ref.read(currentUserProvider).value;
    if (user == null) return;

    final messaging = _ref.read(firebaseMessagingProvider);

    // Subscribe to blood group topic if active donor
    if (user.isBloodDonorActive && user.bloodGroup != null) {
      final bloodTopic = 'blood_${user.bloodGroup!.replaceAll('+', 'pos').replaceAll('-', 'neg')}';
      await messaging.subscribeToTopic(bloodTopic);
    }

    // Subscribe to food rescues nearby topic if location is locked
    if (user.hasLocation) {
      // Use first 4 characters of geohash prefix representing ~20km search radius box
      final geohashPrefix = user.geohash.substring(0, 4);
      final foodTopic = 'food_nearby_$geohashPrefix';
      await messaging.subscribeToTopic(foodTopic);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final user = _ref.read(currentUserProvider).value;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection(FirebaseConstants.usersCollection)
        .doc(user.uid)
        .collection(FirebaseConstants.notificationsCollection)
        .doc(notificationId)
        .update({'read': true});
  }

  Future<void> markAllAsRead() async {
    final user = _ref.read(currentUserProvider).value;
    if (user == null) return;

    final batch = FirebaseFirestore.instance.batch();
    final snapshot = await FirebaseFirestore.instance
        .collection(FirebaseConstants.usersCollection)
        .doc(user.uid)
        .collection(FirebaseConstants.notificationsCollection)
        .where('read', isEqualTo: false)
        .get();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'read': true});
    }

    await batch.commit();
  }

  Future<void> deleteNotification(String notificationId) async {
    final user = _ref.read(currentUserProvider).value;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection(FirebaseConstants.usersCollection)
        .doc(user.uid)
        .collection(FirebaseConstants.notificationsCollection)
        .doc(notificationId)
        .delete();
  }

  Future<void> _updateUserFcmToken(String token) async {
    final user = _ref.read(currentUserProvider).value;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection(FirebaseConstants.usersCollection)
        .doc(user.uid)
        .update({'fcmToken': token});
  }

  void dispose() {
    _tokenSubscription?.cancel();
    _foregroundSubscription?.cancel();
    _tapSubscription?.cancel();
    _initialized = false;
  }
}
