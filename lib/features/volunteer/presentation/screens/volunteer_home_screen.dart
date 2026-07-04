import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:community_care_hub/features/volunteer/presentation/providers/volunteer_provider.dart';
import 'package:community_care_hub/features/volunteer/presentation/widgets/task_card.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:community_care_hub/core/widgets/loading_shimmer.dart';
import 'package:community_care_hub/core/widgets/empty_state.dart';
import 'package:community_care_hub/core/widgets/error_state.dart';
import 'package:community_care_hub/navigation/app_routes.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';
import 'package:community_care_hub/core/utils/geo_utils.dart';

class VolunteerHomeScreen extends ConsumerWidget {
  const VolunteerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(nearbyVolunteerTasksProvider);
    final userAsync = ref.watch(currentUserProvider);
    final selectedFilter = ref.watch(volunteerTypeFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Missions', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go(AppRoutes.home),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => context.push(AppRoutes.volunteerHistory),
            tooltip: 'My Task History',
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User session missing.'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reliability Score Box
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.tertiarySurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.tertiary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.star_rounded, color: AppColors.tertiary, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Volunteer Trust Score',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.tertiaryDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Your Reliability Index: ${(user.reliabilityScore * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.neutral900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${user.totalVolunteerTasks} Done',
                          style: const TextStyle(
                            color: AppColors.tertiaryDark,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Active Tasks Header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Missions Available Near You',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral900,
                  ),
                ),
              ),

              // Horizontal Filter Chips
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  children: [
                    _buildFilterChip(ref, null, 'All Missions'),
                    _buildFilterChip(ref, 'rescue', 'Food Rescue'),
                    _buildFilterChip(ref, 'distribution', 'Distribution'),
                    _buildFilterChip(ref, 'event', 'Community Event'),
                    _buildFilterChip(ref, 'other', 'Other Help'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Missions List
              Expanded(
                child: tasksAsync.when(
                  data: (tasks) {
                    if (tasks.isEmpty) {
                      return EmptyState(
                        icon: Icons.volunteer_activism_rounded,
                        title: 'No Missions Found',
                        subtitle: selectedFilter == null
                            ? 'There are no active volunteer missions listed in your range.'
                            : 'No volunteer tasks matching "$selectedFilter" type found.',
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(nearbyVolunteerTasksProvider);
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: LoadingShimmer.list(count: 3),
                  ),
                  error: (err, stack) => ErrorState(
                    message: err.toString(),
                    onRetry: () => ref.invalidate(nearbyVolunteerTasksProvider),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorState(message: err.toString()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.createVolunteerTask),
        backgroundColor: AppColors.tertiary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Create Mission', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFilterChip(WidgetRef ref, String? value, String label) {
    final selectedValue = ref.watch(volunteerTypeFilterProvider);
    final isSelected = selectedValue == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            ref.read(volunteerTypeFilterProvider.notifier).state = value;
          }
        },
        selectedColor: AppColors.tertiarySurface,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.tertiaryDark : AppColors.neutral800,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
