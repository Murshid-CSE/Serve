import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:community_care_hub/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:community_care_hub/core/widgets/empty_state.dart';
import 'package:community_care_hub/core/widgets/loading_shimmer.dart';
import 'package:community_care_hub/core/extensions/datetime_extension.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsListProvider);
    final manager = ref.read(notificationManagerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_chat_read_rounded),
            onPressed: () async {
              await manager.markAllAsRead();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All notifications marked as read.')),
                );
              }
            },
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'All Caught Up',
              subtitle: 'You do not have any notification alerts right now.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(notificationsListProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];

                return Dismissible(
                  key: Key(notification.id),
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.emergency,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete_rounded, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    manager.deleteNotification(notification.id);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: notification.read ? Colors.white : AppColors.primarySurface.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: notification.read ? AppColors.neutral200 : AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      onTap: () async {
                        // 1. Mark as read
                        if (!notification.read) {
                          await manager.markAsRead(notification.id);
                        }
                        // 2. Redirect route if exists
                        if (context.mounted && notification.route != null) {
                          context.push(notification.route!);
                        }
                      },
                      leading: CircleAvatar(
                        backgroundColor: notification.read ? AppColors.neutral200 : AppColors.primarySurface,
                        child: Icon(
                          notification.read ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                          color: notification.read ? AppColors.neutral600 : AppColors.primary,
                        ),
                      ),
                      title: Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
                          color: AppColors.neutral900,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            notification.body,
                            style: const TextStyle(fontSize: 13, color: AppColors.neutral700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            notification.createdAt.timeAgo,
                            style: const TextStyle(fontSize: 11, color: AppColors.neutral500),
                          ),
                        ],
                      ),
                      trailing: !notification.read
                          ? Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(16.0),
          child: LoadingShimmer.list(count: 3),
        ),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
