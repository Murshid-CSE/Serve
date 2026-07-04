import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_care_hub/features/volunteer/data/datasources/volunteer_remote_datasource.dart';
import 'package:community_care_hub/features/volunteer/data/repositories/volunteer_repository_impl.dart';
import 'package:community_care_hub/features/volunteer/domain/entities/volunteer_task_entity.dart';
import 'package:community_care_hub/features/volunteer/domain/repositories/volunteer_repository.dart';
import 'package:community_care_hub/features/volunteer/domain/usecases/get_nearby_tasks.dart';
import 'package:community_care_hub/features/volunteer/domain/usecases/join_task.dart';
import 'package:community_care_hub/features/volunteer/domain/usecases/leave_task.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';

// Remote DataSource Provider
final volunteerRemoteDataSourceProvider = Provider<VolunteerRemoteDataSource>((ref) {
  return VolunteerRemoteDataSource();
});

// Repository Provider
final volunteerRepositoryProvider = Provider<VolunteerRepository>((ref) {
  return VolunteerRepositoryImpl(ref.watch(volunteerRemoteDataSourceProvider));
});

// Use Case Providers
final getNearbyTasksUseCaseProvider = Provider<GetNearbyTasks>((ref) {
  return GetNearbyTasks(ref.watch(volunteerRepositoryProvider));
});

final joinTaskUseCaseProvider = Provider<JoinTask>((ref) {
  return JoinTask(ref.watch(volunteerRepositoryProvider));
});

final leaveTaskUseCaseProvider = Provider<LeaveTask>((ref) {
  return LeaveTask(ref.watch(volunteerRepositoryProvider));
});

// Radius filter provider
final volunteerSearchRadiusProvider = StateProvider<double>((ref) => 10.0);

// Selected task type filter provider
final volunteerTypeFilterProvider = StateProvider<String?>((ref) => null);

// Nearby Volunteer Tasks Provider
final nearbyVolunteerTasksProvider = FutureProvider<List<VolunteerTaskEntity>>((ref) async {
  final userAsync = ref.watch(currentUserProvider);
  final radius = ref.watch(volunteerSearchRadiusProvider);
  final typeFilter = ref.watch(volunteerTypeFilterProvider);

  final user = userAsync.value;
  if (user == null || !user.hasLocation) {
    return [];
  }

  final list = await ref.read(getNearbyTasksUseCaseProvider).call(
        latitude: user.latitude,
        longitude: user.longitude,
        radiusKm: radius,
      );

  if (typeFilter != null) {
    return list.where((task) => task.type == typeFilter).toList();
  }
  return list;
});

// User's joined tasks list provider
final userVolunteerTasksProvider = FutureProvider<List<VolunteerTaskEntity>>((ref) async {
  final userAsync = ref.watch(currentUserProvider);
  final user = userAsync.value;
  if (user == null) return [];

  return ref.watch(volunteerRepositoryProvider).getUserTasks(user.uid);
});

// Tasks created by user provider
final createdVolunteerTasksProvider = FutureProvider<List<VolunteerTaskEntity>>((ref) async {
  final userAsync = ref.watch(currentUserProvider);
  final user = userAsync.value;
  if (user == null) return [];

  return ref.watch(volunteerRepositoryProvider).getCreatedTasks(user.uid);
});

// Volunteer Actions Provider
final volunteerActionsProvider = Provider<VolunteerActions>((ref) {
  return VolunteerActions(ref.watch(volunteerRepositoryProvider));
});

class VolunteerActions {
  final VolunteerRepository _repository;

  VolunteerActions(this._repository);

  Future<VolunteerTaskEntity> createTask({
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
  }) {
    return _repository.createVolunteerTask(
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
  }

  Future<void> joinTask({required String taskId, required String userId}) {
    return _repository.joinVolunteerTask(taskId: taskId, userId: userId);
  }

  Future<void> leaveTask({required String taskId, required String userId}) {
    return _repository.leaveVolunteerTask(taskId: taskId, userId: userId);
  }
}
