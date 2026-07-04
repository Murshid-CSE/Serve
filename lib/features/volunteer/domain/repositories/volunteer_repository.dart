import 'package:community_care_hub/features/volunteer/domain/entities/volunteer_task_entity.dart';

abstract class VolunteerRepository {
  Future<List<VolunteerTaskEntity>> getNearbyVolunteerTasks({
    required double latitude,
    required double longitude,
    required double radiusKm,
  });

  Future<void> joinVolunteerTask({
    required String taskId,
    required String userId,
  });

  Future<void> leaveVolunteerTask({
    required String taskId,
    required String userId,
  });

  Future<List<VolunteerTaskEntity>> getUserTasks(String userId);

  Future<List<VolunteerTaskEntity>> getCreatedTasks(String userId);

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
  });
}
