import 'package:community_care_hub/features/volunteer/domain/repositories/volunteer_repository.dart';

class LeaveTask {
  final VolunteerRepository _repository;

  const LeaveTask(this._repository);

  Future<void> call({
    required String taskId,
    required String userId,
  }) {
    return _repository.leaveVolunteerTask(
      taskId: taskId,
      userId: userId,
    );
  }
}
