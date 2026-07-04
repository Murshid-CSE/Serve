import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:community_care_hub/features/emergency/domain/entities/emergency_alert_entity.dart';
import 'package:community_care_hub/features/emergency/domain/repositories/emergency_repository.dart';
import 'package:community_care_hub/features/emergency/data/datasources/emergency_remote_datasource.dart';
import 'package:community_care_hub/core/errors/app_exception.dart';

class EmergencyRepositoryImpl implements EmergencyRepository {
  final EmergencyRemoteDataSource _remoteDataSource;
  final Connectivity _connectivity = Connectivity();

  EmergencyRepositoryImpl(this._remoteDataSource);

  Future<void> _checkConnectivity() async {
    final status = await _connectivity.checkConnectivity();
    if (status.contains(ConnectivityResult.none)) {
      throw const NetworkException();
    }
  }

  @override
  Future<List<EmergencyAlertEntity>> getNearbyEmergencyAlerts({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    try {
      return await _remoteDataSource.getNearbyEmergencyAlerts(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  @override
  Future<void> respondToEmergencyAlert({
    required String alertId,
    required String userId,
  }) async {
    await _checkConnectivity();
    try {
      await _remoteDataSource.respondToEmergencyAlert(
        alertId: alertId,
        userId: userId,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  @override
  Future<EmergencyAlertEntity> createEmergencyAlert({
    required String title,
    required String description,
    required String level,
    required String address,
    required double latitude,
    required double longitude,
    required String contactPhone,
  }) async {
    await _checkConnectivity();
    try {
      return await _remoteDataSource.createEmergencyAlert(
        title: title,
        description: description,
        level: level,
        address: address,
        latitude: latitude,
        longitude: longitude,
        contactPhone: contactPhone,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }
}
