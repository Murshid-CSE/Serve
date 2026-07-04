import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_care_hub/features/notifications/domain/entities/app_notification_entity.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:community_care_hub/core/constants/firebase_constants.dart';

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
  return NotificationManager(ref);
});

class NotificationManager {
  final Ref _ref;

  NotificationManager(this._ref);

  /// Initializes messaging and requests permission
  Future<void> initializeNotifications() async {
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
    messaging.onTokenRefresh.listen((newToken) {
      _updateUserFcmToken(newToken);
    });
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

    for (var doc in snapshot.docs) {
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
}
