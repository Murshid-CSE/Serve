import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:community_care_hub/features/food/domain/entities/food_donation_entity.dart';
import 'package:community_care_hub/core/constants/firebase_constants.dart';
import 'package:community_care_hub/core/utils/geo_utils.dart';
import 'package:community_care_hub/core/errors/app_exception.dart';

class FoodRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  /// Create a food donation record in Firestore + upload image if provided
  Future<FoodDonationEntity> createFoodDonation({
    required String title,
    required String description,
    required String category,
    required String quantity,
    required String pickupAddress,
    required double latitude,
    required double longitude,
    required int expiryHours,
    required String donorId,
    required String donorName,
    required String donorPhone,
    required String? imagePath,
  }) async {
    try {
      final id = _uuid.v4();
      String? imageUrl;

      // 1. Upload compressed image if path is present
      if (imagePath != null) {
        final ref = _storage
            .ref()
            .child(FirebaseConstants.foodImagesPath)
            .child('$id.jpg');
        final uploadTask = await ref.putFile(File(imagePath));
        imageUrl = await uploadTask.ref.getDownloadURL();
      }

      final geohash = GeoUtils.encodeGeohash(latitude, longitude, precision: 7);
      final createdAt = DateTime.now();
      final expiresAt = createdAt.add(Duration(hours: expiryHours));

      final donation = FoodDonationEntity(
        id: id,
        donorId: donorId,
        donorName: donorName,
        donorPhone: donorPhone,
        title: title,
        description: description,
        category: category,
        quantity: quantity,
        imageUrl: imageUrl,
        status: 'available',
        pickupAddress: pickupAddress,
        latitude: latitude,
        longitude: longitude,
        geohash: geohash,
        expiresAt: expiresAt,
        createdAt: createdAt,
      );

      await _firestore
          .collection(FirebaseConstants.foodDonationsCollection)
          .doc(id)
          .set(donation.toMap());

      return donation;
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e);
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  /// Query nearby food donations using Geohash prefix range
  Future<List<FoodDonationEntity>> getNearbyFoodDonations({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    try {
      final prefix = GeoUtils.getGeohashPrefix(latitude, longitude, radiusKm);
      final range = GeoUtils.getGeohashRange(prefix);

      final snapshot = await _firestore
          .collection(FirebaseConstants.foodDonationsCollection)
          .where('status', isEqualTo: 'available')
          .where('pickupLocation.geohash', isGreaterThanOrEqualTo: range[0])
          .where('pickupLocation.geohash', isLessThanOrEqualTo: range[1])
          .get();

      final list = snapshot.docs
          .map((doc) => FoodDonationEntity.fromMap(doc.data()))
          .toList();

      // Post-filter list by exact Haversine distance and expiry time
      final activeList = list.where((item) => !item.isExpired).toList();

      final filtered = GeoUtils.filterByDistance<FoodDonationEntity>(
        items: activeList,
        centerLat: latitude,
        centerLng: longitude,
        radiusKm: radiusKm,
        getLatitude: (item) => item.latitude,
        getLongitude: (item) => item.longitude,
      );

      return GeoUtils.sortByDistance<FoodDonationEntity>(
        items: filtered,
        centerLat: latitude,
        centerLng: longitude,
        getLatitude: (item) => item.latitude,
        getLongitude: (item) => item.longitude,
      );
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e);
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  /// Accept food donation with transaction to prevent race conditions
  Future<void> acceptFoodDonation({
    required String donationId,
    required String userId,
    required String userName,
  }) async {
    final docRef = _firestore
        .collection(FirebaseConstants.foodDonationsCollection)
        .doc(donationId);

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw const FirestoreException(message: 'Item not found');
        }

        final data = snapshot.data();
        if (data == null) {
          throw const FirestoreException(message: 'Item contains no data');
        }

        final status = data['status'] as String? ?? 'available';
        final expiresAt = (data['expiresAt'] as Timestamp).toDate();

        if (status != 'available') {
          throw const FirestoreException(message: 'Item is no longer available');
        }

        if (DateTime.now().isAfter(expiresAt)) {
          throw const FirestoreException(message: 'Item has expired');
        }

        transaction.update(docRef, {
          'status': 'accepted',
          'acceptedBy': userId,
          'acceptedByName': userName,
          'acceptedAt': FieldValue.serverTimestamp(),
        });
      });
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e);
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  /// Update food donation status
  Future<void> updateFoodDonationStatus({
    required String donationId,
    required String status,
  }) async {
    try {
      final Map<String, dynamic> updates = {'status': status};

      if (status == 'collected') {
        updates['collectedAt'] = FieldValue.serverTimestamp();
      } else if (status == 'delivered') {
        updates['deliveredAt'] = FieldValue.serverTimestamp();
      } else if (status == 'completed') {
        updates['completedAt'] = FieldValue.serverTimestamp();
      }

      await _firestore
          .collection(FirebaseConstants.foodDonationsCollection)
          .doc(donationId)
          .update(updates);
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e);
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  /// Get donations submitted by a specific donor
  Future<List<FoodDonationEntity>> getUserDonations(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.foodDonationsCollection)
          .where('donorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FoodDonationEntity.fromMap(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e);
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  /// Get tasks accepted by a volunteer
  Future<List<FoodDonationEntity>> getAcceptedTasks(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.foodDonationsCollection)
          .where('acceptedBy', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FoodDonationEntity.fromMap(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e);
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }
}
