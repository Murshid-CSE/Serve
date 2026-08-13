import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:community_care_hub/features/food/domain/entities/food_donation_entity.dart';
import 'package:community_care_hub/features/food/domain/repositories/food_repository.dart';
import 'package:community_care_hub/features/food/data/datasources/food_remote_datasource.dart';
import 'package:community_care_hub/core/errors/app_exception.dart';

class FoodRepositoryImpl implements FoodRepository {

  FoodRepositoryImpl(this._remoteDataSource);
  final FoodRemoteDataSource _remoteDataSource;
  final Connectivity _connectivity = Connectivity();

  Future<void> _checkConnectivity() async {
    final status = await _connectivity.checkConnectivity();
    if (status.contains(ConnectivityResult.none)) {
      throw const NetworkException();
    }
  }

  @override
  Future<FoodDonationEntity> createFoodDonation({
    required String title,
    required String description,
    required String category,
    required String quantity,
    required String pickupAddress,
    required double latitude,
    required double longitude,
    required int expiryHours,
    required String? imagePath,
  }) async {
    await _checkConnectivity();
    final fbUser = fb.FirebaseAuth.instance.currentUser;
    if (fbUser == null) {
      throw const AuthException(message: 'User must be logged in to create a donation.');
    }

    try {
      return await _remoteDataSource.createFoodDonation(
        title: title,
        description: description,
        category: category,
        quantity: quantity,
        pickupAddress: pickupAddress,
        latitude: latitude,
        longitude: longitude,
        expiryHours: expiryHours,
        donorId: fbUser.uid,
        donorName: fbUser.displayName ?? 'Donor',
        donorPhone: fbUser.phoneNumber ?? '',
        imagePath: imagePath,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  @override
  Stream<List<FoodDonationEntity>> getNearbyFoodDonations({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) {
    // Read operations fallback to cache if offline (managed by Firestore settings)
    try {
      return _remoteDataSource.getNearbyFoodDonations(
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
  Future<void> acceptFoodDonation({
    required String donationId,
    required String userId,
    required String userName,
  }) async {
    await _checkConnectivity();
    try {
      await _remoteDataSource.acceptFoodDonation(
        donationId: donationId,
        userId: userId,
        userName: userName,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  @override
  Future<void> updateFoodDonationStatus({
    required String donationId,
    required String status,
  }) async {
    await _checkConnectivity();
    try {
      await _remoteDataSource.updateFoodDonationStatus(
        donationId: donationId,
        status: status,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  @override
  Stream<List<FoodDonationEntity>> getUserDonations(String userId) {
    try {
      return _remoteDataSource.getUserDonations(userId);
    } on AppException {
      rethrow;
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  @override
  Stream<List<FoodDonationEntity>> getAcceptedTasks(String userId) {
    try {
      return _remoteDataSource.getAcceptedTasks(userId);
    } on AppException {
      rethrow;
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }
}
