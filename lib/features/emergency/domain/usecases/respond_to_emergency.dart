import 'package:community_care_hub/features/emergency/domain/repositories/emergency_repository.dart';

class RespondToEmergency {

  const RespondToEmergency(this.repository);
  final EmergencyRepository repository;

  Future<void> call({
    required String alertId,
    required String userId,
  }) {
    return repository.respondToEmergencyAlert(
      alertId: alertId,
      userId: userId,
    );
  }
}
