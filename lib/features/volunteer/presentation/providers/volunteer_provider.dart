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

// Raw Nearby Volunteer Tasks Stream (does not restart on task type filter change)
final _rawNearbyVolunteerTasksProvider = StreamProvider.autoDispose<List<VolunteerTaskEntity>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final radius = ref.watch(volunteerSearchRadiusProvider);

  final user = userAsync.value;
  if (user == null || !user.hasLocation) {
    return Stream.value([]);
  }

  return ref.watch(getNearbyTasksUseCaseProvider).call(
        latitude: user.latitude,
        longitude: user.longitude,
        radiusKm: radius,
      );
});

// Filtered Nearby Volunteer Tasks Provider (rebuilds only when filter or raw stream changes)
final nearbyVolunteerTasksProvider = Provider.autoDispose<AsyncValue<List<VolunteerTaskEntity>>>((ref) {
  final rawData = ref.watch(_rawNearbyVolunteerTasksProvider);
  final typeFilter = ref.watch(volunteerTypeFilterProvider);

  return rawData.whenData((list) {
    if (typeFilter != null) {
      return list.where((task) => task.type == typeFilter).toList();
    }
    return list;
  });
});

// User's joined tasks list provider
final userVolunteerTasksProvider = StreamProvider.autoDispose<List<VolunteerTaskEntity>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final user = userAsync.value;
  if (user == null) return Stream.value([]);

  return ref.watch(volunteerRepositoryProvider).getUserTasks(user.uid);
});

// Tasks created by user provider
final createdVolunteerTasksProvider = StreamProvider.autoDispose<List<VolunteerTaskEntity>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final user = userAsync.value;
  if (user == null) return Stream.value([]);

  return ref.watch(volunteerRepositoryProvider).getCreatedTasks(user.uid);
});

// Volunteer Actions Provider
final volunteerActionsProvider = Provider<VolunteerActions>((ref) {
  return VolunteerActions(ref.watch(volunteerRepositoryProvider));
});

class VolunteerActions {

  VolunteerActions(this._repository);
  final VolunteerRepository _repository;

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
