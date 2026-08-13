import 'package:community_care_hub/features/blood/domain/repositories/blood_repository.dart';

class ToggleAvailability {

  const ToggleAvailability(this._repository);
  final BloodRepository _repository;

  Future<void> call({required bool isAvailable}) {
    return _repository.toggleAvailability(isAvailable: isAvailable);
  }
}
