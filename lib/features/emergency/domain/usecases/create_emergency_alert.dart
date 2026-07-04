import 'package:community_care_hub/features/emergency/domain/entities/emergency_alert_entity.dart';
import 'package:community_care_hub/features/emergency/domain/repositories/emergency_repository.dart';

class CreateEmergencyAlert {
  final EmergencyRepository repository;

  const CreateEmergencyAlert(this.repository);

  Future<EmergencyAlertEntity> call({
    required String title,
    required String description,
    required String level,
    required String address,
    required double latitude,
    required double longitude,
    required String contactPhone,
  }) {
    return repository.createEmergencyAlert(
      title: title,
      description: description,
      level: level,
      address: address,
      latitude: latitude,
      longitude: longitude,
      contactPhone: contactPhone,
    );
  }
}
