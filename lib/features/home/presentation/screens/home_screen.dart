import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:community_care_hub/features/home/presentation/widgets/module_card.dart';
import 'package:community_care_hub/features/home/presentation/widgets/stats_banner.dart';
import 'package:community_care_hub/features/home/presentation/widgets/recent_activity_tile.dart';
import 'package:community_care_hub/core/widgets/section_header.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';
import 'package:community_care_hub/navigation/app_routes.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User not signed in.'));
          }

          final greeting = _getGreeting();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(currentUserProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Curved Header Hero Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      top: 60,
                      left: 20,
                      right: 20,
                      bottom: 30,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: AppColors.heroGradient,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row with greeting + notification bell + avatar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.white24,
                                    backgroundImage: user.photoUrl != null
                                        ? CachedNetworkImageProvider(user.photoUrl!)
                                        : null,
                                    child: user.photoUrl == null
                                        ? Text(
                                            user.name.isNotEmpty
                                                ? user.name[0].toUpperCase()
                                                : 'U',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          greeting,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          user.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Notification bell
                            IconButton(
                              onPressed: () {
                                context.push(AppRoutes.notifications);
                              },
                              icon: const Icon(
                                Icons.notifications_none_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        // Impact statement
                        Text(
                          'Your Care Impact Score: ${user.impactScore.round()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Thank you for keeping the coordination workflow alive!',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Quick Stats Banner Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: StatsBanner(
                      foodSaved: user.totalFoodDonations,
                      bloodDonated: user.totalBloodDonations,
                      tasksCompleted: user.totalVolunteerTasks,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Module Cards Section
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Explore Services',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Grid of 4 module cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.15,
                      children: [
                        ModuleCard(
                          title: 'Food Rescue',
                          subtitle: 'Rescue surplus food',
                          icon: Icons.restaurant_rounded,
                          gradient: AppColors.foodGradient,
                          onTap: () => context.push(AppRoutes.foodHome),
                        ),
                        ModuleCard(
                          title: 'Blood Support',
                          subtitle: 'Emergency requests',
                          icon: Icons.bloodtype_rounded,
                          gradient: AppColors.bloodGradient,
                          onTap: () => context.push(AppRoutes.bloodHome),
                        ),
                        ModuleCard(
                          title: 'Volunteer Hub',
                          subtitle: 'Accept tasks nearby',
                          icon: Icons.volunteer_activism_rounded,
                          gradient: AppColors.volunteerGradient,
                          onTap: () => context.push(AppRoutes.volunteerHome),
                        ),
                        ModuleCard(
                          title: 'Emergency Response',
                          subtitle: 'Broadcast alerts',
                          icon: Icons.bolt_rounded,
                          gradient: AppColors.emergencyGradient,
                          onTap: () => context.push(AppRoutes.emergency),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Recent Activity Feed Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SectionHeader(
                      title: 'Recent Activity',
                      actionLabel: 'View Leaderboard',
                      onAction: () => context.push(AppRoutes.leaderboard),
                    ),
                  ),

                  // List of recent activities
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.infoSurface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Sample Activity — Real-time feed coming soon',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.info,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const RecentActivityTile(
                          icon: Icons.restaurant_rounded,
                          iconColor: AppColors.foodModule,
                          title: 'Surplus Cooked Meals Shared',
                          subtitle: 'Delivered to Shelter home',
                          timeAgo: '2h ago',
                        ),
                        const RecentActivityTile(
                          icon: Icons.bloodtype_rounded,
                          iconColor: AppColors.bloodModule,
                          title: 'Emergency Request Posted',
                          subtitle: 'O+ blood required at City Hospital',
                          timeAgo: '4h ago',
                        ),
                        const RecentActivityTile(
                          icon: Icons.check_circle_rounded,
                          iconColor: AppColors.success,
                          title: 'Joined Care Hub Network',
                          subtitle: 'Registered as a Humanitarian Hero',
                          timeAgo: '1d ago',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
        loading: () => _buildShimmerLoading(context),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.neutral200,
      highlightColor: AppColors.neutral100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            color: Colors.white,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(height: 20, width: 120, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: Container(height: 130, color: Colors.white)),
                const SizedBox(width: 16),
                Expanded(child: Container(height: 130, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
