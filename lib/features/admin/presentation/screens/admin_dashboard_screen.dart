import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:community_care_hub/features/auth/domain/entities/user_entity.dart';
import 'package:community_care_hub/core/widgets/app_card.dart';
import 'package:community_care_hub/core/widgets/loading_shimmer.dart';
import 'package:community_care_hub/core/widgets/error_state.dart';
import 'package:community_care_hub/core/constants/firebase_constants.dart';
import 'package:community_care_hub/core/widgets/app_button.dart';
import 'package:community_care_hub/navigation/app_routes.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';
import 'package:community_care_hub/core/extensions/context_extension.dart';

// Admin users stream provider
final adminUsersListProvider = StreamProvider<List<UserEntity>>((ref) {
  return FirebaseFirestore.instance
      .collection(FirebaseConstants.usersCollection)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => UserEntity.fromMap(doc.data())).toList();
  });
});

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _updateUserRole(UserEntity user, String newRole) async {
    final confirmed = await context.showConfirmDialog(
      title: 'Update User Role',
      message: 'Are you sure you want to update ${user.name}\'s role to ${newRole.toUpperCase()}?',
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .update({'role': newRole});

      if (!mounted) return;
      context.showSuccessSnackBar('User role updated to ${newRole.toUpperCase()}.');
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackBar('Failed to update role: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersListProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.neutral600,
          tabs: const [
            Tab(icon: Icon(Icons.people_rounded), text: 'Users Management'),
            Tab(icon: Icon(Icons.analytics_rounded), text: 'Platform Metrics'),
          ],
        ),
      ),
      body: userAsync.when(
        data: (currentUser) {
          if (currentUser == null || !currentUser.isAdmin) {
            return const Center(child: Text('Access Denied: Admin privileges required.'));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Users List with role updates
              usersAsync.when(
                data: (users) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final u = users[index];
                      final isSelf = u.uid == currentUser.uid;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.neutral200),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primarySurface,
                              child: Text(
                                u.name.isNotEmpty ? u.name[0].toUpperCase() : 'U',
                                style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    u.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  Text(
                                    u.email,
                                    style: const TextStyle(fontSize: 12, color: AppColors.neutral500),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.neutral100,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: AppColors.neutral300),
                                    ),
                                    child: Text(
                                      u.role.toUpperCase(),
                                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isSelf)
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert_rounded),
                                onSelected: (role) => _updateUserRole(u, role),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'donor', child: Text('Make Donor')),
                                  const PopupMenuItem(value: 'volunteer', child: Text('Make Volunteer')),
                                  const PopupMenuItem(value: 'both', child: Text('Make Both')),
                                  const PopupMenuItem(value: 'admin', child: Text('Make Admin')),
                                ],
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: LoadingShimmer.list(count: 3),
                ),
                error: (err, stack) => ErrorState(message: err.toString()),
              ),

              // Tab 2: General Stats Overview
              usersAsync.when(
                data: (users) {
                  final totalUsers = users.length;
                  final totalDonors = users.where((u) => u.isDonor).length;
                  final totalVolunteers = users.where((u) => u.isVolunteer).length;
                  final totalAdmins = users.where((u) => u.isAdmin).length;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'System Statistics',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.neutral900),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildMetricCard('Total Users', '$totalUsers', Icons.people_rounded, AppColors.info)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildMetricCard('Active Donors', '$totalDonors', Icons.favorite_rounded, AppColors.primary)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildMetricCard('Volunteers', '$totalVolunteers', Icons.volunteer_activism_rounded, AppColors.tertiary)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildMetricCard('Admins', '$totalAdmins', Icons.admin_panel_settings_rounded, AppColors.secondary)),
                          ],
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Management Tools',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.neutral900),
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          label: 'Manage Detailed Users & Roles',
                          onPressed: () => context.push(AppRoutes.adminUsers),
                          icon: Icons.manage_accounts_rounded,
                          variant: AppButtonVariant.outlined,
                          isExpanded: true,
                          color: AppColors.info,
                        ),
                        const SizedBox(height: 12),
                        AppButton(
                          label: 'Manage Contributions & Requests',
                          onPressed: () => context.push(AppRoutes.adminRequests),
                          icon: Icons.task_rounded,
                          variant: AppButtonVariant.outlined,
                          isExpanded: true,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => ErrorState(message: err.toString()),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorState(message: err.toString()),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.neutral900),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppColors.neutral500),
          ),
        ],
      ),
    );
  }
}
