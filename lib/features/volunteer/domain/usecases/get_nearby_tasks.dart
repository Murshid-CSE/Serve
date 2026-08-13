import 'package:community_care_hub/features/volunteer/domain/entities/volunteer_task_entity.dart';
import 'package:community_care_hub/features/volunteer/domain/repositories/volunteer_repository.dart';

class GetNearbyTasks {

  const GetNearbyTasks(this._repository);
  final VolunteerRepository _repository;

  Stream<List<VolunteerTaskEntity>> call({
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
