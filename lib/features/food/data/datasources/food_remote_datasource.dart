import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'package:community_care_hub/features/food/domain/entities/food_donation_entity.dart';
import 'package:community_care_hub/core/constants/firebase_constants.dart';
import 'package:community_care_hub/core/utils/geo_utils.dart';
import 'package:community_care_hub/core/errors/app_exception.dart';
import 'package:community_care_hub/core/services/cloudinary_service.dart';

class FoodRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
    final id = _uuid.v4();
    String? imageUrl;
    String? imagePublicId;
    String? deleteToken;

    try {
      // 1. Upload compressed image if path is present
      if (imagePath != null) {
        final uploadResult = await CloudinaryService.uploadFoodImage(File(imagePath));
        imageUrl = uploadResult.secureUrl;
        imagePublicId = uploadResult.publicId;
        deleteToken = uploadResult.deleteToken;
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
        imagePublicId: imagePublicId,
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
      if (deleteToken != null) {
        await CloudinaryService.deleteByToken(deleteToken);
      }
      throw FirestoreException.fromFirebase(e);
    } catch (e) {
      if (deleteToken != null) {
        await CloudinaryService.deleteByToken(deleteToken);
      }
      if (e is AppException) rethrow;
      throw FirestoreException(message: e.toString());
    }
  }

  /// Query nearby food donations using multi-range geohash neighbor queries
  Stream<List<FoodDonationEntity>> getNearbyFoodDonations({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) {
    try {
      final ranges = GeoUtils.getGeohashQueryRanges(latitude, longitude, radiusKm);

      // Create a Firestore snapshot stream for each geohash range
      final streams = ranges.map((range) {
        return _firestore
            .collection(FirebaseConstants.foodDonationsCollection)
            .where('status', isEqualTo: 'available')
            .where('pickupLocation.geohash', isGreaterThanOrEqualTo: range[0])
            .where('pickupLocation.geohash', isLessThanOrEqualTo: range[1])
            .snapshots();
      }).toList();

      // Combine all streams, deduplicate by document ID, filter by distance
      return CombineLatestStream.list(streams).map((snapshots) {
        final allDocs = <String, FoodDonationEntity>{};
        for (final snapshot in snapshots) {
          for (final doc in snapshot.docs) {
            allDocs[doc.id] = FoodDonationEntity.fromMap(doc.data());
          }
        }
        final list = allDocs.values.toList();

        // Post-filter by expiry and exact Haversine distance
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
      });
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
      const validStatuses = {
        'available',
        'accepted',
        'collected',
        'delivered',
        'completed',
        'expired',
        'cancelled',
      };

      if (!validStatuses.contains(status)) {
        throw ValidationException(message: 'Invalid status: $status');
      }

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
  Stream<List<FoodDonationEntity>> getUserDonations(String userId) {
    try {
      return _firestore
          .collection(FirebaseConstants.foodDonationsCollection)
          .where('donorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => FoodDonationEntity.fromMap(doc.data()))
              .toList());
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e);
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  /// Get tasks accepted by a volunteer
  Stream<List<FoodDonationEntity>> getAcceptedTasks(String userId) {
    try {
      return _firestore
          .collection(FirebaseConstants.foodDonationsCollection)
          .where('acceptedBy', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => FoodDonationEntity.fromMap(doc.data()))
              .toList());
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e);
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }
}
