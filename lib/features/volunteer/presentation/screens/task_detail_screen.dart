import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:community_care_hub/features/volunteer/presentation/providers/volunteer_provider.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:community_care_hub/core/widgets/app_button.dart';
import 'package:community_care_hub/core/widgets/loading_shimmer.dart';
import 'package:community_care_hub/core/widgets/error_state.dart';
import 'package:community_care_hub/core/extensions/context_extension.dart';
import 'package:community_care_hub/core/extensions/datetime_extension.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {

  const TaskDetailScreen({
    super.key,
    required this.taskId,
  });
  final String taskId;

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  bool _isActionLoading = false;

  Future<void> _handleJoin(String userId) async {
    setState(() {
      _isActionLoading = true;
    });

    try {
      await ref.read(joinTaskUseCaseProvider).call(
            taskId: widget.taskId,
            userId: userId,
          );

      if (!mounted) return;
      context.showSuccessSnackBar('You have successfully joined this mission. Thank you!');
      ref.invalidate(nearbyVolunteerTasksProvider);
      ref.invalidate(userVolunteerTasksProvider);
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackBar(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isActionLoading = false;
        });
      }
    }
  }

  Future<void> _handleLeave(String userId) async {
    final confirmed = await context.showConfirmDialog(
      title: 'Leave Mission?',
      message: 'Are you sure you want to opt out of this volunteer task? Leaving tasks frequently might impact your Reliability score.',
      confirmText: 'Leave Task',
      isDangerous: true,
    );

    if (confirmed != true) return;

    setState(() {
      _isActionLoading = true;
    });

    try {
      await ref.read(leaveTaskUseCaseProvider).call(
            taskId: widget.taskId,
            userId: userId,
          );

      if (!mounted) return;
      context.showSuccessSnackBar('You have opted out of this volunteer mission.');
      ref.invalidate(nearbyVolunteerTasksProvider);
      ref.invalidate(userVolunteerTasksProvider);
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackBar(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isActionLoading = false;
        });
      }
    }
  }

  Color _getColorForType(String type) {
    return switch (type) {
      'rescue' => AppColors.secondary,
      'distribution' => AppColors.info,
      'event' => AppColors.tertiary,
      _ => AppColors.neutral700,
    };
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(nearbyVolunteerTasksProvider);
    final userTasksAsync = ref.watch(userVolunteerTasksProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mission Details', style: TextStyle(fontWeight: FontWeight.bold)),
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

          // Search in all lists
          final allTasks = [
            ...?tasksAsync.value,
            ...?userTasksAsync.value,
          ];

          final taskIndex = allTasks.indexWhere((t) => t.id == widget.taskId);
          if (taskIndex == -1) {
            return const Center(child: Text('Mission details not found.'));
          }

          final task = allTasks[taskIndex];
          final hasJoined = task.volunteersJoined.contains(user.uid);
          final isFull = task.volunteersJoined.length >= task.volunteersNeeded;
          final typeColor = _getColorForType(task.type);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type tag chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      task.type.toUpperCase(),
                      style: TextStyle(
                        color: typeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Title & Creator
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Organized by: ${task.creatorName}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.neutral600,
                    ),
                  ),
                  const Divider(height: 32, color: AppColors.neutral200),

                  // Date & Location Info Cards
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.neutral100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Date & Time', style: TextStyle(fontSize: 11, color: AppColors.neutral500)),
                              const SizedBox(height: 6),
                              Text(task.date.formatDate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(task.date.formatTime, style: const TextStyle(color: AppColors.neutral600, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.neutral100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Volunteers', style: TextStyle(fontSize: 11, color: AppColors.neutral500)),
                              const SizedBox(height: 6),
                              Text('${task.volunteersJoined.length} / ${task.volunteersNeeded}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const Text('Seats Filled', style: TextStyle(color: AppColors.neutral600, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  const Text('Mission Description', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    task.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.neutral700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Location address
                  const Text('Location / Address', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_rounded, color: AppColors.tertiary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            task.address,
                            style: const TextStyle(fontSize: 13, color: AppColors.neutral700, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Actions
                  if (hasJoined)
                    AppButton(
                      label: 'Opt Out of Mission',
                      onPressed: _isActionLoading ? null : () => _handleLeave(user.uid),
                      isLoading: _isActionLoading,
                      isExpanded: true,
                      variant: AppButtonVariant.outlined,
                      color: AppColors.emergency,
                    )
                  else
                    AppButton(
                      label: isFull ? 'Mission Seats Full' : 'Join Volunteer Mission',
                      onPressed: (isFull || _isActionLoading) ? null : () => _handleJoin(user.uid),
                      isLoading: _isActionLoading,
                      isExpanded: true,
                      variant: AppButtonVariant.filled,
                      color: AppColors.tertiary,
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingShimmer.detail(),
        error: (err, stack) => ErrorState(message: err.toString()),
      ),
    );
  }
}
