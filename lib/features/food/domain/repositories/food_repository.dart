import 'package:community_care_hub/features/food/domain/entities/food_donation_entity.dart';

abstract class FoodRepository {
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
  });

  Stream<List<FoodDonationEntity>> getNearbyFoodDonations({
    required double latitude,
    required double longitude,
    required double radiusKm,
  });

  Future<void> acceptFoodDonation({
    required String donationId,
    required String userId,
    required String userName,
  });

  Future<void> updateFoodDonationStatus({
    required String donationId,
    required String status,
  });

  Stream<List<FoodDonationEntity>> getUserDonations(String userId);

  Stream<List<FoodDonationEntity>> getAcceptedTasks(String userId);
}
