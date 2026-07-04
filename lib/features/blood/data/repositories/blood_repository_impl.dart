import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:community_care_hub/features/blood/domain/entities/blood_request_entity.dart';
import 'package:community_care_hub/features/blood/domain/entities/blood_donor_entity.dart';
import 'package:community_care_hub/features/blood/domain/repositories/blood_repository.dart';
import 'package:community_care_hub/features/blood/data/datasources/blood_remote_datasource.dart';
import 'package:community_care_hub/core/errors/app_exception.dart';

class BloodRepositoryImpl implements BloodRepository {
  final BloodRemoteDataSource _remoteDataSource;
  final Connectivity _connectivity = Connectivity();

  BloodRepositoryImpl(this._remoteDataSource);

  Future<void> _checkConnectivity() async {
    final status = await _connectivity.checkConnectivity();
    if (status.contains(ConnectivityResult.none)) {
      throw const NetworkException();
    }
  }

  @override
  Future<void> registerBloodDonor({
    required String bloodGroup,
    required bool isAvailable,
  }) async {
    await _checkConnectivity();
    final fbUser = fb.FirebaseAuth.instance.currentUser;
    if (fbUser == null) {
      throw const AuthException(message: 'User must be logged in to register as donor.');
    }

    try {
      await _remoteDataSource.registerBloodDonor(
        userId: fbUser.uid,
        bloodGroup: bloodGroup,
        isAvailable: isAvailable,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  @override
  Future<BloodRequestEntity> createBloodRequest({
    required String patientName,
    required String bloodGroup,
    required int unitsNeeded,
    required String hospitalName,
    required String hospitalAddress,
    required double latitude,
    required double longitude,
    required bool isEmergency,
  }) async {
    await _checkConnectivity();
    final fbUser = fb.FirebaseAuth.instance.currentUser;
    if (fbUser == null) {
      throw const AuthException(message: 'User must be logged in to create a blood request.');
    }

    try {
      return await _remoteDataSource.createBloodRequest(
        requesterId: fbUser.uid,
        requesterName: fbUser.displayName ?? 'Requester',
        requesterPhone: fbUser.phoneNumber ?? '',
        patientName: patientName,
        bloodGroup: bloodGroup,
        unitsNeeded: unitsNeeded,
        hospitalName: hospitalName,
        hospitalAddress: hospitalAddress,
        latitude: latitude,
        longitude: longitude,
        isEmergency: isEmergency,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  @override
  Future<List<BloodDonorEntity>> getNearbyDonors({
    required String bloodGroup,
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    try {
      return await _remoteDataSource.getNearbyDonors(
        requestedBloodGroup: bloodGroup,
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  @override
  Future<List<BloodRequestEntity>> getActiveRequests() async {
    try {
      return await _remoteDataSource.getActiveRequests();
    } on AppException {
      rethrow;
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  @override
  Future<void> respondToRequest({
    required String requestId,
    required String userId,
  }) async {
    await _checkConnectivity();
    try {
      await _remoteDataSource.respondToRequest(
        requestId: requestId,
        userId: userId,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  @override
  Future<void> toggleAvailability({required bool isAvailable}) async {
    await _checkConnectivity();
    final fbUser = fb.FirebaseAuth.instance.currentUser;
    if (fbUser == null) {
      throw const AuthException(message: 'User session missing.');
    }

    try {
      await _remoteDataSource.toggleAvailability(
        userId: fbUser.uid,
        isAvailable: isAvailable,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  @override
  Future<List<BloodRequestEntity>> getUserRequests(String userId) async {
    try {
      return await _remoteDataSource.getUserRequests(userId);
    } on AppException {
      rethrow;
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }
}
