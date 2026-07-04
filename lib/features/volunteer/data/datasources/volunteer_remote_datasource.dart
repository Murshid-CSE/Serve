import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_care_hub/features/volunteer/domain/entities/volunteer_task_entity.dart';
import 'package:community_care_hub/core/constants/firebase_constants.dart';
import 'package:community_care_hub/core/utils/geo_utils.dart';
import 'package:community_care_hub/core/errors/app_exception.dart';

class VolunteerRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get nearby volunteer tasks using geohash prefix range
  Future<List<VolunteerTaskEntity>> getNearbyVolunteerTasks({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    try {
      final prefix = GeoUtils.getGeohashPrefix(latitude, longitude, radiusKm);
      final range = GeoUtils.getGeohashRange(prefix);

      final snapshot = await _firestore
          .collection(FirebaseConstants.volunteerTasksCollection)
          .where('status', isEqualTo: 'active')
          .where('location.geohash', isGreaterThanOrEqualTo: range[0])
          .where('location.geohash', isLessThanOrEqualTo: range[1])
          .get();

      final list = snapshot.docs
          .map((doc) => VolunteerTaskEntity.fromMap(doc.data()))
          .toList();

      // Post-filter by distance and date
      final activeList = list.where((item) => item.date.isAfter(DateTime.now())).toList();

      final filtered = GeoUtils.filterByDistance<VolunteerTaskEntity>(
        items: activeList,
        centerLat: latitude,
        centerLng: longitude,
        radiusKm: radiusKm,
        getLatitude: (t) => t.latitude,
        getLongitude: (t) => t.longitude,
      );

      return GeoUtils.sortByDistance<VolunteerTaskEntity>(
        items: filtered,
        centerLat: latitude,
        centerLng: longitude,
        getLatitude: (t) => t.latitude,
        getLongitude: (t) => t.longitude,
      );
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e);
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  /// Join a volunteer task using a transaction
  Future<void> joinVolunteerTask({
    required String taskId,
    required String userId,
  }) async {
    final docRef = _firestore
        .collection(FirebaseConstants.volunteerTasksCollection)
        .doc(taskId);

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw const FirestoreException(message: 'Task not found');
        }

        final data = snapshot.data();
        if (data == null) {
          throw const FirestoreException(message: 'Task contains no data');
        }

        final list = List<String>.from(data['volunteersJoined'] ?? []);
        final limit = data['volunteersNeeded'] as int? ?? 1;

        if (list.contains(userId)) {
          throw const FirestoreException(message: 'You have already joined this task');
        }

        if (list.length >= limit) {
          throw const FirestoreException(message: 'This task is already full');
        }

        transaction.update(docRef, {
          'volunteersJoined': FieldValue.arrayUnion([userId]),
        });
      });
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e);
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  /// Leave a volunteer task
  Future<void> leaveVolunteerTask({
    required String taskId,
    required String userId,
  }) async {
    try {
      await _firestore
          .collection(FirebaseConstants.volunteerTasksCollection)
          .doc(taskId)
          .update({
        'volunteersJoined': FieldValue.arrayRemove([userId]),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e);
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  /// Get tasks that the user has joined
  Future<List<VolunteerTaskEntity>> getUserTasks(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.volunteerTasksCollection)
          .where('volunteersJoined', arrayContains: userId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => VolunteerTaskEntity.fromMap(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e);
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  /// Get tasks created by this user
  Future<List<VolunteerTaskEntity>> getCreatedTasks(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.volunteerTasksCollection)
          .where('creatorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => VolunteerTaskEntity.fromMap(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e);
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  /// Create a new volunteer task
  Future<VolunteerTaskEntity> createVolunteerTask({
    required String title,
    required String description,
    required String type,
    required String address,
    required double latitude,
    required double longitude,
    required DateTime date,
    required int volunteersNeeded,
    required String creatorId,
    required String creatorName,
  }) async {
    try {
      final docRef = _firestore.collection(FirebaseConstants.volunteerTasksCollection).doc();
      final geohash = GeoUtils.encodeGeohash(latitude, longitude);

      final task = VolunteerTaskEntity(
        id: docRef.id,
        title: title,
        description: description,
        type: type,
        status: 'active',
        address: address,
        latitude: latitude,
        longitude: longitude,
        geohash: geohash,
        date: date,
        volunteersNeeded: volunteersNeeded,
        volunteersJoined: const [],
        creatorId: creatorId,
        creatorName: creatorName,
        createdAt: DateTime.now(),
      );

      await docRef.set(task.toMap());
      return task;
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e);
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }
}
