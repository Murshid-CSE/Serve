import 'package:community_care_hub/features/emergency/domain/entities/emergency_alert_entity.dart';

abstract class EmergencyRepository {
  Future<List<EmergencyAlertEntity>> getNearbyEmergencyAlerts({
    required double latitude,
    required double longitude,
    required double radiusKm,
  });

  Future<void> respondToEmergencyAlert({
    required String alertId,
    required String userId,
  });

  Future<EmergencyAlertEntity> createEmergencyAlert({
    required String title,
    required String description,
    required String level,
    required String address,
    required double latitude,
    required double longitude,
    required String contactPhone,
  });
}
