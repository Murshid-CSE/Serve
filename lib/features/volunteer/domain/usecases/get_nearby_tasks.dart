import 'package:community_care_hub/features/volunteer/domain/entities/volunteer_task_entity.dart';
import 'package:community_care_hub/features/volunteer/domain/repositories/volunteer_repository.dart';

class GetNearbyTasks {
  final VolunteerRepository _repository;

  const GetNearbyTasks(this._repository);

  Future<List<VolunteerTaskEntity>> call({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) {
    return _repository.getNearbyVolunteerTasks(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );
  }
}
