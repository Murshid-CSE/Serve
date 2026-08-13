import 'package:community_care_hub/features/food/domain/entities/food_donation_entity.dart';
import 'package:community_care_hub/features/food/domain/repositories/food_repository.dart';

class GetNearbyFood {

  const GetNearbyFood(this._repository);
  final FoodRepository _repository;

  Stream<List<FoodDonationEntity>> call({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) {
    return _repository.getNearbyFoodDonations(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );
  }
}
