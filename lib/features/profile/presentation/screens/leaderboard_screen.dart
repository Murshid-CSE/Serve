import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:community_care_hub/features/auth/domain/entities/user_entity.dart';
import 'package:community_care_hub/core/widgets/loading_shimmer.dart';
import 'package:community_care_hub/core/widgets/error_state.dart';
import 'package:community_care_hub/core/constants/firebase_constants.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';

// Leaderboard list provider - Fetches top 50 users sorted by impactScore
final leaderboardUsersProvider = FutureProvider<List<UserEntity>>((ref) async {
  final snapshot = await FirebaseFirestore.instance
      .collection(FirebaseConstants.usersCollection)
      .orderBy('impactScore', descending: true)
      .limit(50)
      .get();

  return snapshot.docs.map((doc) => UserEntity.fromMap(doc.data())).toList();
});

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardUsersProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Champions', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: userAsync.when(
        data: (currentUser) {
          if (currentUser == null) {
            return const Center(child: Text('User session missing.'));
          }

          return leaderboardAsync.when(
            data: (users) {
              if (users.isEmpty) {
                return const Center(child: Text('No leaderboard entries found yet.'));
              }

              // Extract top 3 and list of others
              final topThree = users.take(3).toList();
              final runnersUp = users.skip(3).toList();

              return Column(
                children: [
                  // 1. Top 3 Podium area
                  if (topThree.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      decoration: const BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                      child: _buildPodium(context, topThree),
                    ),

                  // 2. Others list
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(leaderboardUsersProvider);
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: runnersUp.length,
                        itemBuilder: (context, index) {
                          final user = runnersUp[index];
                          final rank = index + 4; // top 3 skipped
                          final isMe = user.uid == currentUser.uid;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isMe ? AppColors.primarySurface : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isMe ? AppColors.primary.withValues(alpha: 0.3) : AppColors.neutral200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '#$rank',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.neutral600),
                                ),
                                const SizedBox(width: 16),
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.primarySurface,
                                  backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                                  child: user.photoUrl == null
                                      ? Text(
                                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                          style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.name,
                                        style: TextStyle(
                                          fontWeight: isMe ? FontWeight.bold : FontWeight.w600,
                                          fontSize: 15,
                                          color: AppColors.neutral900,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        user.role.toUpperCase(),
                                        style: const TextStyle(fontSize: 10, color: AppColors.neutral500),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${user.impactScore.toStringAsFixed(0)} PTS',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(16.0),
              child: LoadingShimmer.list(count: 4),
            ),
            error: (err, stack) => ErrorState(
              message: err.toString(),
              onRetry: () => ref.invalidate(leaderboardUsersProvider),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorState(message: err.toString()),
      ),
    );
  }

  Widget _buildPodium(BuildContext context, List<UserEntity> topThree) {
    // topThree[0] = Gold, topThree[1] = Silver (if exists), topThree[2] = Bronze (if exists)
    final gold = topThree[0];
    final silver = topThree.length > 1 ? topThree[1] : null;
    final bronze = topThree.length > 2 ? topThree[2] : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd Place: Silver
        if (silver != null)
          _buildPodiumSpot(
            user: silver,
            rank: 2,
            height: 100,
            color: const Color(0xFFB0BEC5),
            scoreText: '${silver.impactScore.toStringAsFixed(0)} PTS',
          ),

        // 1st Place: Gold
        _buildPodiumSpot(
          user: gold,
          rank: 1,
          height: 130,
          color: const Color(0xFFFFD54F),
          scoreText: '${gold.impactScore.toStringAsFixed(0)} PTS',
        ),

        // 3rd Place: Bronze
        if (bronze != null)
          _buildPodiumSpot(
            user: bronze,
            rank: 3,
            height: 80,
            color: const Color(0xFFFFB74D),
            scoreText: '${bronze.impactScore.toStringAsFixed(0)} PTS',
          ),
      ],
    );
  }

  Widget _buildPodiumSpot({
    required UserEntity user,
    required int rank,
    required double height,
    required Color color,
    required String scoreText,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar + Crown
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: CircleAvatar(
                radius: rank == 1 ? 32 : 26,
                backgroundColor: color,
                child: CircleAvatar(
                  radius: rank == 1 ? 29 : 23,
                  backgroundColor: Colors.white,
                  backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                  child: user.photoUrl == null
                      ? Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                          style: TextStyle(
                            fontSize: rank == 1 ? 20 : 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.neutral800,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            if (rank == 1)
              const Positioned(
                top: 0,
                child: Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD54F), size: 20),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Name
        Container(
          constraints: const BoxConstraints(maxWidth: 80),
          child: Text(
            user.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.neutral900),
          ),
        ),
        const SizedBox(height: 4),

        // Score
        Text(
          scoreText,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: color),
        ),
        const SizedBox(height: 8),

        // Podium Column
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.9),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$rank',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
