import 'package:community_care_hub/features/blood/domain/repositories/blood_repository.dart';

class RegisterBloodDonor {
  final BloodRepository _repository;

  const RegisterBloodDonor(this._repository);

  Future<void> call({
    required String bloodGroup,
    required bool isAvailable,
  }) {
    return _repository.registerBloodDonor(
      bloodGroup: bloodGroup,
      isAvailable: isAvailable,
    );
  }
}
