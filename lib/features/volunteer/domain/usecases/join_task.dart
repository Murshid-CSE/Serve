import 'package:community_care_hub/features/volunteer/domain/repositories/volunteer_repository.dart';

class JoinTask {
  final VolunteerRepository _repository;

  const JoinTask(this._repository);

  Future<void> call({
    required String taskId,
    required String userId,
  }) {
    return _repository.joinVolunteerTask(
      taskId: taskId,
      userId: userId,
    );
  }
}
