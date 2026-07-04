import 'package:community_care_hub/features/emergency/domain/entities/emergency_alert_entity.dart';
import 'package:community_care_hub/features/emergency/domain/repositories/emergency_repository.dart';

class GetNearbyEmergencies {
  final EmergencyRepository repository;

  const GetNearbyEmergencies(this.repository);

  Future<List<EmergencyAlertEntity>> call({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) {
    return repository.getNearbyEmergencyAlerts(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );
  }
}
