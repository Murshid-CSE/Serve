import 'package:community_care_hub/features/blood/domain/entities/blood_request_entity.dart';
import 'package:community_care_hub/features/blood/domain/repositories/blood_repository.dart';

class CreateBloodRequest {

  const CreateBloodRequest(this._repository);
  final BloodRepository _repository;

  Future<BloodRequestEntity> call({
    required String patientName,
    required String bloodGroup,
    required int unitsNeeded,
    required String hospitalName,
    required String hospitalAddress,
    required double latitude,
    required double longitude,
    required bool isEmergency,
  }) {
    return _repository.createBloodRequest(
      patientName: patientName,
      bloodGroup: bloodGroup,
      unitsNeeded: unitsNeeded,
      hospitalName: hospitalName,
      hospitalAddress: hospitalAddress,
      latitude: latitude,
      longitude: longitude,
      isEmergency: isEmergency,
    );
  }
}
