import 'package:community_care_hub/features/food/domain/entities/food_donation_entity.dart';
import 'package:community_care_hub/features/food/domain/repositories/food_repository.dart';

class CreateFoodDonation {
  final FoodRepository _repository;

  const CreateFoodDonation(this._repository);

  Future<FoodDonationEntity> call({
    required String title,
    required String description,
    required String category,
    required String quantity,
    required String pickupAddress,
    required double latitude,
    required double longitude,
    required int expiryHours,
    required String? imagePath,
  }) {
    return _repository.createFoodDonation(
      title: title,
      description: description,
      category: category,
      quantity: quantity,
      pickupAddress: pickupAddress,
      latitude: latitude,
      longitude: longitude,
      expiryHours: expiryHours,
      imagePath: imagePath,
    );
  }
}
