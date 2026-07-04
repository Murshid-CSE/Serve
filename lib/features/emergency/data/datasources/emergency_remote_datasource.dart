import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_care_hub/features/emergency/domain/entities/emergency_alert_entity.dart';
import 'package:community_care_hub/core/constants/firebase_constants.dart';
import 'package:community_care_hub/core/utils/geo_utils.dart';
import 'package:community_care_hub/core/errors/app_exception.dart';

class EmergencyRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get nearby emergency alerts using geohash range queries
  Future<List<EmergencyAlertEntity>> getNearbyEmergencyAlerts({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    try {
      final prefix = GeoUtils.getGeohashPrefix(latitude, longitude, radiusKm);
      final range = GeoUtils.getGeohashRange(prefix);

      final snapshot = await _firestore
          .collection(FirebaseConstants.emergencyRequestsCollection)
          .where('location.geohash', isGreaterThanOrEqualTo: range[0])
          .where('location.geohash', isLessThanOrEqualTo: range[1])
          .get();

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
      await _firestore
          .collection(FirebaseConstants.emergencyRequestsCollection)
          .doc(alertId)
          .update({
        'responders': FieldValue.arrayUnion([userId]),
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
}
