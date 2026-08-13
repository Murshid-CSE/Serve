import 'package:community_care_hub/features/blood/domain/entities/blood_donor_entity.dart';
import 'package:community_care_hub/features/blood/domain/repositories/blood_repository.dart';

class GetNearbyDonors {

  const GetNearbyDonors(this._repository);
  final BloodRepository _repository;

  Future<List<BloodDonorEntity>> call({
    required String bloodGroup,
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) {
    return _repository.getNearbyDonors(
      bloodGroup: bloodGroup,
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );
  }
}
