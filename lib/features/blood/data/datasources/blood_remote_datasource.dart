import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:community_care_hub/features/blood/domain/entities/blood_request_entity.dart';
import 'package:community_care_hub/features/blood/domain/entities/blood_donor_entity.dart';
import 'package:community_care_hub/core/constants/firebase_constants.dart';
import 'package:community_care_hub/core/utils/geo_utils.dart';
import 'package:community_care_hub/core/errors/app_exception.dart';

class BloodRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // 8-Group Compatibility Matrix
  static const Map<String, List<String>> compatibilityMap = {
    'A+':  ['A+', 'A-', 'O+', 'O-'],
    'A-':  ['A-', 'O-'],
    'B+':  ['B+', 'B-', 'O+', 'O-'],
    'B-':  ['B-', 'O-'],
    'AB+': ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
    'AB-': ['A-', 'B-', 'AB-', 'O-'],
    'O+':  ['O+', 'O-'],
    'O-':  ['O-'],
  };

  /// Register user as active blood donor (updates user document fields)
  Future<void> registerBloodDonor({
    required String userId,
    required String bloodGroup,
    required bool isAvailable,
  }) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .update({
        'bloodGroup': bloodGroup,
        'isBloodDonorActive': isAvailable,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e);
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  /// Create a blood request record in Firestore
  Future<BloodRequestEntity> createBloodRequest({
    required String requesterId,
    required String requesterName,
    required String requesterPhone,
    required String patientName,
    required String bloodGroup,
    required int unitsNeeded,
    required String hospitalName,
    required String hospitalAddress,
    required double latitude,
    required double longitude,
    required bool isEmergency,
  }) async {
    try {
      final id = _uuid.v4();
      final geohash = GeoUtils.encodeGeohash(latitude, longitude, precision: 7);
      final createdAt = DateTime.now();
      final expiresAt = createdAt.add(FirebaseConstants.bloodDefaultExpiry);

      final request = BloodRequestEntity(
        id: id,
        requesterId: requesterId,
        requesterName: requesterName,
        requesterPhone: requesterPhone,
        patientName: patientName,
        bloodGroup: bloodGroup,
        unitsNeeded: unitsNeeded,
        hospitalName: hospitalName,
        hospitalAddress: hospitalAddress,
        latitude: latitude,
        longitude: longitude,
        geohash: geohash,
        isEmergency: isEmergency,
        status: 'open',
        respondedBy: [],
        expiresAt: expiresAt,
        createdAt: createdAt,
      );

      await _firestore
          .collection(FirebaseConstants.bloodRequestsCollection)
          .doc(id)
          .set(request.toMap());

      return request;
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e);
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  /// Query nearby compatible blood donors
  Future<List<BloodDonorEntity>> getNearbyDonors({
    required String requestedBloodGroup,
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    try {
      // 1. Get compatible blood group types for the requested group
      final compatibleGroups = compatibilityMap[requestedBloodGroup] ?? [requestedBloodGroup];

      final prefix = GeoUtils.getGeohashPrefix(latitude, longitude, radiusKm);
      final range = GeoUtils.getGeohashRange(prefix);

      // 2. Fetch active donors from users collection who match geohash range
      final snapshot = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .where('isBloodDonorActive', isEqualTo: true)
          .where('location.geohash', isGreaterThanOrEqualTo: range[0])
          .where('location.geohash', isLessThanOrEqualTo: range[1])
          .get();

      final allDonors = snapshot.docs
          .map((doc) => BloodDonorEntity.fromMap(doc.data()))
          .toList();

      // 3. Post-filter compatibility & distance
      final compatibleDonors = allDonors.where((donor) {
        return compatibleGroups.contains(donor.bloodGroup);
      }).toList();

      final filtered = GeoUtils.filterByDistance<BloodDonorEntity>(
        items: compatibleDonors,
        centerLat: latitude,
        centerLng: longitude,
        radiusKm: radiusKm,
        getLatitude: (d) => d.latitude,
        getLongitude: (d) => d.longitude,
      );

      return GeoUtils.sortByDistance<BloodDonorEntity>(
        items: filtered,
        centerLat: latitude,
        centerLng: longitude,
        getLatitude: (d) => d.latitude,
        getLongitude: (d) => d.longitude,
      );
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e);
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  /// Get active open blood requests from Firestore
  Future<List<BloodRequestEntity>> getActiveRequests() async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.bloodRequestsCollection)
          .where('status', whereIn: ['open', 'responding'])
          .orderBy('createdAt', descending: true)
          .get();

      final list = snapshot.docs
          .map((doc) => BloodRequestEntity.fromMap(doc.data()))
          .toList();

      // Filter expired items client-side
      return list.where((item) => !item.isExpired).toList();
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e);
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  /// Respond to blood request
  Future<void> respondToRequest({
    required String requestId,
    required String userId,
  }) async {
    try {
      await _firestore
          .collection(FirebaseConstants.bloodRequestsCollection)
          .doc(requestId)
          .update({
        'respondedBy': FieldValue.arrayUnion([userId]),
        'status': 'responding',
      });
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e);
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  /// Toggle availability of the donor
  Future<void> toggleAvailability({
    required String userId,
    required bool isAvailable,
  }) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userId)
          .update({
        'isBloodDonorActive': isAvailable,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e);
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  /// Get requests submitted by a specific user
  Future<List<BloodRequestEntity>> getUserRequests(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.bloodRequestsCollection)
          .where('requesterId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => BloodRequestEntity.fromMap(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e);
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }
}
