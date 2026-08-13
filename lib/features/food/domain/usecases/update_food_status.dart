import 'package:community_care_hub/features/food/domain/repositories/food_repository.dart';

class UpdateFoodStatus {

  const UpdateFoodStatus(this._repository);
  final FoodRepository _repository;

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
