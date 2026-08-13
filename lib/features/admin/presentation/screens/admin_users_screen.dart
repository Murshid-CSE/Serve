import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:community_care_hub/features/auth/domain/entities/user_entity.dart';
import 'package:community_care_hub/core/widgets/loading_shimmer.dart';
import 'package:community_care_hub/core/widgets/error_state.dart';
import 'package:community_care_hub/core/widgets/empty_state.dart';
import 'package:community_care_hub/core/constants/firebase_constants.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';
import 'package:community_care_hub/core/extensions/context_extension.dart';

// Searchable users provider
final _searchQueryProvider = StateProvider<String>((ref) => '');

final _filteredUsersProvider = StreamProvider<List<UserEntity>>((ref) {
  return FirebaseFirestore.instance
      .collection(FirebaseConstants.usersCollection)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    final query = ref.watch(_searchQueryProvider).toLowerCase();
    final users = snapshot.docs.map((doc) => UserEntity.fromMap(doc.data())).toList();
    if (query.isEmpty) return users;
    return users.where((u) =>
        u.name.toLowerCase().contains(query) ||
        u.email.toLowerCase().contains(query) ||
        u.role.toLowerCase().contains(query)).toList();
  });
});

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _updateRole(UserEntity user, String newRole) async {
    final confirmed = await context.showConfirmDialog(
      title: 'Change Role',
      message: 'Change ${user.name}\'s role to ${newRole.toUpperCase()}?',
    );
    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .update({'role': newRole});
      if (mounted) context.showSuccessSnackBar('Role updated to $newRole.');
    } catch (e) {
      if (mounted) context.showErrorSnackBar('Failed: $e');
    }
  }

  Future<void> _deleteUser(UserEntity user) async {
    final confirmed = await context.showConfirmDialog(
      title: 'Delete User',
      message: 'Are you sure you want to delete ${user.name}? This action cannot be undone.',
      confirmText: 'Delete',
      isDangerous: true,
    );
    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .delete();
      if (mounted) context.showSuccessSnackBar('User deleted.');
    } catch (e) {
      if (mounted) context.showErrorSnackBar('Failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(_filteredUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, email, or role...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(_searchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                ref.read(_searchQueryProvider.notifier).state = value;
              },
            ),
          ),

          // Users List
          Expanded(
            child: usersAsync.when(
              loading: () => const LoadingShimmer.list(count: 6),
              error: (error, stack) => ErrorState(
                message: 'Failed to load users',
                onRetry: () => ref.invalidate(_filteredUsersProvider),
              ),
              data: (users) {
                if (users.isEmpty) {
                  return const EmptyState(
                    icon: Icons.people_outline_rounded,
                    title: 'No Users Found',
                    subtitle: 'No users match your search criteria.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return _UserTile(
                      user: user,
                      onChangeRole: (role) => _updateRole(user, role),
                      onDelete: () => _deleteUser(user),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {

  const _UserTile({
    required this.user,
    required this.onChangeRole,
    required this.onDelete,
  });
  final UserEntity user;
  final ValueChanged<String> onChangeRole;
  final VoidCallback onDelete;

  Color _roleColor(String role) {
    switch (role) {
      case 'admin': return AppColors.emergency;
      case 'volunteer': return AppColors.tertiary;
      case 'donor': return AppColors.secondary;
      case 'both': return AppColors.info;
      default: return AppColors.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primarySurface,
          backgroundImage: user.photoUrl != null ? CachedNetworkImageProvider(user.photoUrl!) : null,
          child: user.photoUrl == null
              ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))
              : null,
        ),
        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _roleColor(user.role).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    user.role.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _roleColor(user.role)),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '⭐ ${user.impactScore.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          onSelected: (value) {
            if (value == 'delete') {
              onDelete();
            } else {
              onChangeRole(value);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'donor', child: Text('Set as Donor')),
            const PopupMenuItem(value: 'volunteer', child: Text('Set as Volunteer')),
            const PopupMenuItem(value: 'both', child: Text('Set as Both')),
            const PopupMenuItem(value: 'admin', child: Text('Set as Admin')),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete User', style: TextStyle(color: AppColors.emergency)),
            ),
          ],
        ),
      ),
    );
  }
}
