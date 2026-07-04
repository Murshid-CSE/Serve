import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_care_hub/features/emergency/data/datasources/emergency_remote_datasource.dart';
import 'package:community_care_hub/features/emergency/data/repositories/emergency_repository_impl.dart';
import 'package:community_care_hub/features/emergency/domain/entities/emergency_alert_entity.dart';
import 'package:community_care_hub/features/emergency/domain/repositories/emergency_repository.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';

// Remote DataSource Provider
final emergencyRemoteDataSourceProvider = Provider<EmergencyRemoteDataSource>((ref) {
  return EmergencyRemoteDataSource();
});

// Repository Provider
final emergencyRepositoryProvider = Provider<EmergencyRepository>((ref) {
  return EmergencyRepositoryImpl(ref.watch(emergencyRemoteDataSourceProvider));
});

// Search Radius Provider (15.0km default for emergency)
final emergencySearchRadiusProvider = StateProvider<double>((ref) => 15.0);

// Nearby Emergency Alerts Provider
final nearbyEmergencyAlertsProvider = FutureProvider<List<EmergencyAlertEntity>>((ref) async {
  final userAsync = ref.watch(currentUserProvider);
  final radius = ref.watch(emergencySearchRadiusProvider);

  final user = userAsync.value;
  if (user == null || !user.hasLocation) {
    return [];
  }

  return ref.read(emergencyRepositoryProvider).getNearbyEmergencyAlerts(
        latitude: user.latitude,
        longitude: user.longitude,
        radiusKm: radius,
      );
});

// Emergency Actions class for use cases
final emergencyActionsProvider = Provider<EmergencyActions>((ref) {
  return EmergencyActions(ref.watch(emergencyRepositoryProvider));
});

class EmergencyActions {
  final EmergencyRepository _repository;

  EmergencyActions(this._repository);

  Future<void> respondToEmergency({required String alertId, required String userId}) {
    return _repository.respondToEmergencyAlert(alertId: alertId, userId: userId);
  }

  Future<EmergencyAlertEntity> createEmergencyAlert({
    required String title,
    required String description,
    required String level,
    required String address,
    required double latitude,
    required double longitude,
    required String contactPhone,
  }) {
    return _repository.createEmergencyAlert(
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
