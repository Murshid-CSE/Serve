import 'package:community_care_hub/features/food/domain/repositories/food_repository.dart';

class AcceptFoodDonation {
  final FoodRepository _repository;

  const AcceptFoodDonation(this._repository);

  Future<void> call({
    required String donationId,
    required String userId,
    required String userName,
  }) {
    return _repository.acceptFoodDonation(
      donationId: donationId,
      userId: userId,
      userName: userName,
    );
  }
}
