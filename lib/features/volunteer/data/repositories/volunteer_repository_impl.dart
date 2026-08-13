import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:community_care_hub/features/volunteer/domain/entities/volunteer_task_entity.dart';
import 'package:community_care_hub/features/volunteer/domain/repositories/volunteer_repository.dart';
import 'package:community_care_hub/features/volunteer/data/datasources/volunteer_remote_datasource.dart';
import 'package:community_care_hub/core/errors/app_exception.dart';

class VolunteerRepositoryImpl implements VolunteerRepository {

  VolunteerRepositoryImpl(this._remoteDataSource);
  final VolunteerRemoteDataSource _remoteDataSource;
  final Connectivity _connectivity = Connectivity();

  Future<void> _checkConnectivity() async {
    final status = await _connectivity.checkConnectivity();
    if (status.contains(ConnectivityResult.none)) {
      throw const NetworkException();
    }
  }

  @override
  Stream<List<VolunteerTaskEntity>> getNearbyVolunteerTasks({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) {
    try {
      return _remoteDataSource.getNearbyVolunteerTasks(
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
  Future<void> joinVolunteerTask({
    required String taskId,
    required String userId,
  }) async {
    await _checkConnectivity();
    try {
      await _remoteDataSource.joinVolunteerTask(
        taskId: taskId,
        userId: userId,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  @override
  Future<void> leaveVolunteerTask({
    required String taskId,
    required String userId,
  }) async {
    await _checkConnectivity();
    try {
      await _remoteDataSource.leaveVolunteerTask(
        taskId: taskId,
        userId: userId,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  @override
  Stream<List<VolunteerTaskEntity>> getUserTasks(String userId) {
    try {
      return _remoteDataSource.getUserTasks(userId);
    } on AppException {
      rethrow;
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  @override
  Stream<List<VolunteerTaskEntity>> getCreatedTasks(String userId) {
    try {
      return _remoteDataSource.getCreatedTasks(userId);
    } on AppException {
      rethrow;
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  @override
  Future<VolunteerTaskEntity> createVolunteerTask({
    required String title,
    required String description,
    required String type,
    required String address,
    required double latitude,
    required double longitude,
    required DateTime date,
    required int volunteersNeeded,
    required String creatorId,
    required String creatorName,
  }) async {
    await _checkConnectivity();
    try {
      return await _remoteDataSource.createVolunteerTask(
        title: title,
        description: description,
        type: type,
        address: address,
        latitude: latitude,
        longitude: longitude,
        date: date,
        volunteersNeeded: volunteersNeeded,
        creatorId: creatorId,
        creatorName: creatorName,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }
}
