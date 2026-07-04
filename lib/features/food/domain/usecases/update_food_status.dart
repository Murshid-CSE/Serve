import 'package:community_care_hub/features/food/domain/repositories/food_repository.dart';

class UpdateFoodStatus {
  final FoodRepository _repository;

  const UpdateFoodStatus(this._repository);

  Future<void> call({
    required String donationId,
    required String status,
  }) {
    return _repository.updateFoodDonationStatus(
      donationId: donationId,
      status: status,
    );
  }
}
