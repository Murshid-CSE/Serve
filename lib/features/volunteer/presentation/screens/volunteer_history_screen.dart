import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:community_care_hub/features/volunteer/presentation/providers/volunteer_provider.dart';
import 'package:community_care_hub/features/volunteer/presentation/widgets/task_card.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:community_care_hub/core/widgets/loading_shimmer.dart';
import 'package:community_care_hub/core/widgets/empty_state.dart';
import 'package:community_care_hub/core/widgets/error_state.dart';
import 'package:community_care_hub/core/utils/geo_utils.dart';

class VolunteerHistoryScreen extends ConsumerWidget {
  const VolunteerHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userTasksAsync = ref.watch(userVolunteerTasksProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Volunteer Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User session missing.'));
          }

          return userTasksAsync.when(
            data: (tasks) {
              if (tasks.isEmpty) {
                return EmptyState(
                  icon: Icons.volunteer_activism_rounded,
                  title: 'No Joined Tasks',
                  subtitle: 'You have not joined any volunteer missions yet.',
                  actionLabel: 'Browse Missions',
                  onAction: () => context.pop(),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(userVolunteerTasksProvider);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    double? dist;
                    if (user.hasLocation) {
                      dist = GeoUtils.calculateDistance(
                        user.latitude,
                        user.longitude,
                        task.latitude,
                        task.longitude,
                      );
                    }

                    return TaskCard(
                      task: task,
                      distanceKm: dist,
                      onTap: () {
                        context.push('/volunteer/${task.id}');
                      },
                    );
                  },
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(16.0),
              child: LoadingShimmer.list(count: 3),
            ),
            error: (err, stack) => ErrorState(
              message: err.toString(),
              onRetry: () => ref.invalidate(userVolunteerTasksProvider),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorState(message: err.toString()),
      ),
    );
  }
}
