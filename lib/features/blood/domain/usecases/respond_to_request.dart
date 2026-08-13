import 'package:community_care_hub/features/blood/domain/repositories/blood_repository.dart';

class RespondToRequest {

  const RespondToRequest(this._repository);
  final BloodRepository _repository;

  Future<void> call({
    required String requestId,
    required String userId,
  }) {
    return _repository.respondToRequest(
      requestId: requestId,
      userId: userId,
    );
  }
}
