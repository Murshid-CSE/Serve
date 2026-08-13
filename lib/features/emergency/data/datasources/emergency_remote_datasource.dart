import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_care_hub/features/emergency/domain/entities/emergency_alert_entity.dart';
import 'package:community_care_hub/core/constants/firebase_constants.dart';
import 'package:community_care_hub/core/utils/geo_utils.dart';
import 'package:community_care_hub/core/errors/app_exception.dart';

class EmergencyRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get nearby emergency alerts using geohash range queries (Stream)
  Stream<List<EmergencyAlertEntity>> getNearbyEmergencyAlerts({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) {
    try {
      final prefix = GeoUtils.getGeohashPrefix(latitude, longitude, radiusKm);
      final range = GeoUtils.getGeohashRange(prefix);

      return _firestore
          .collection(FirebaseConstants.emergencyRequestsCollection)
          .where('location.geohash', isGreaterThanOrEqualTo: range[0])
          .where('location.geohash', isLessThanOrEqualTo: range[1])
          .snapshots()
          .map((snapshot) {
        final list = snapshot.docs
            .map((doc) => EmergencyAlertEntity.fromMap(doc.data()))
            .toList();

        final filtered = GeoUtils.filterByDistance<EmergencyAlertEntity>(
          items: list,
          centerLat: latitude,
          centerLng: longitude,
          radiusKm: radiusKm,
          getLatitude: (a) => a.latitude,
          getLongitude: (a) => a.longitude,
        );

        return GeoUtils.sortByDistance<EmergencyAlertEntity>(
          items: filtered,
          centerLat: latitude,
          centerLng: longitude,
          getLatitude: (a) => a.latitude,
          getLongitude: (a) => a.longitude,
        );
      });
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e);
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  /// Respond to an alert (adds user ID to responders list)
  Future<void> respondToEmergencyAlert({
    required String alertId,
    required String userId,
  }) async {
    try {
      final docRef = _firestore
          .collection(FirebaseConstants.emergencyRequestsCollection)
          .doc(alertId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw const FirestoreException(message: 'Emergency alert not found');
        }

        final data = snapshot.data();
        if (data == null) {
          throw const FirestoreException(message: 'Emergency alert contains no data');
        }

        final responders = List<String>.from(data['responders'] ?? []);
        if (responders.contains(userId)) {
          throw const FirestoreException(message: 'You have already responded to this emergency alert');
        }

        transaction.update(docRef, {
          'responders': FieldValue.arrayUnion([userId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e);
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  /// Create a new emergency alert
  Future<EmergencyAlertEntity> createEmergencyAlert({
    required String title,
    required String description,
    required String level,
    required String address,
    required double latitude,
    required double longitude,
    required String contactPhone,
  }) async {
    try {
      final docRef = _firestore
          .collection(FirebaseConstants.emergencyRequestsCollection)
          .doc();

      final geohash = GeoUtils.encodeGeohash(latitude, longitude);
      final currentUser = fb.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw const AuthException(message: 'User must be signed in to create an emergency alert.');
      }

      final alert = EmergencyAlertEntity(
        id: docRef.id,
        title: title,
        description: description,
        level: level,
        address: address,
        latitude: latitude,
        longitude: longitude,
        geohash: geohash,
        responders: [],
        contactPhone: contactPhone,
        creatorId: currentUser.uid,
        createdAt: DateTime.now(),
      );

      await docRef.set(alert.toMap());
      return alert;
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e);
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  /// Get alerts created by a specific user (Stream)
  Stream<List<EmergencyAlertEntity>> getUserAlerts(String userId) {
    try {
      return _firestore
          .collection(FirebaseConstants.emergencyRequestsCollection)
          .where('creatorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => EmergencyAlertEntity.fromMap(doc.data()))
              .toList());
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e);
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  /// Get alerts responded to by a specific user (Stream)
  Stream<List<EmergencyAlertEntity>> getUserResponses(String userId) {
    try {
      return _firestore
          .collection(FirebaseConstants.emergencyRequestsCollection)
          .where('responders', arrayContains: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => EmergencyAlertEntity.fromMap(doc.data()))
              .toList());
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e);
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }
}
