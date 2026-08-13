import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:community_care_hub/core/widgets/app_button.dart';
import 'package:community_care_hub/core/widgets/app_card.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';
import 'package:community_care_hub/navigation/app_routes.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.push(AppRoutes.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User session missing.'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // 1. Header with Avatar & Name
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: const BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary,
                        backgroundImage: user.photoUrl != null ? CachedNetworkImageProvider(user.photoUrl!) : null,
                        child: user.photoUrl == null
                            ? Text(
                                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(fontSize: 14, color: AppColors.neutral600),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.role.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Score Section (Animated Impact Score + Reliability Ring)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      // Impact score animated card
                      Expanded(
                        child: AppCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Icon(Icons.emoji_events_rounded, color: AppColors.secondary, size: 36),
                              const SizedBox(height: 8),
                              const Text('Impact Score', style: TextStyle(fontSize: 12, color: AppColors.neutral500)),
                              const SizedBox(height: 4),
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0, end: user.impactScore),
                                duration: const Duration(seconds: 1),
                                builder: (context, value, child) {
                                  return Text(
                                    value.toStringAsFixed(0),
                                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.neutral900),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Reliability circular ring card
                      Expanded(
                        child: AppCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: CustomPaint(
                                  painter: _ReliabilityRingPainter(
                                    score: user.reliabilityScore,
                                    color: AppColors.tertiary,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${(user.reliabilityScore * 100).toStringAsFixed(0)}%',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.tertiaryDark),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text('Reliability Index', style: TextStyle(fontSize: 12, color: AppColors.neutral500)),
                              const SizedBox(height: 4),
                              const Text('Active', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.neutral900)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Stats Summary Counters
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Contribution Summary',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.neutral900),
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(Icons.food_bank_rounded, AppColors.secondary, '${user.totalFoodDonations}', 'Rescues'),
                            _buildStatItem(Icons.water_drop_rounded, AppColors.primary, '${user.totalBloodDonations}', 'Donated'),
                            _buildStatItem(Icons.volunteer_activism_rounded, AppColors.tertiary, '${user.totalVolunteerTasks}', 'Missions'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Action Buttons (Leaderboard, Edit Settings)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      AppButton(
                        label: 'View Global Leaderboard',
                        onPressed: () => context.push(AppRoutes.leaderboard),
                        icon: Icons.leaderboard_rounded,
                        variant: AppButtonVariant.tonal,
                        isExpanded: true,
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: 'Edit Profile',
                        onPressed: () => context.push(AppRoutes.editProfile),
                        icon: Icons.edit_rounded,
                        variant: AppButtonVariant.outlined,
                        isExpanded: true,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: 'Give Feedback',
                        onPressed: () => context.push(AppRoutes.feedback),
                        icon: Icons.feedback_rounded,
                        variant: AppButtonVariant.outlined,
                        isExpanded: true,
                        color: AppColors.tertiary,
                      ),
                      const SizedBox(height: 12),
                      if (user.isAdmin) ...[
                        const SizedBox(height: 12),
                        AppButton(
                          label: 'Go to Admin Console',
                          onPressed: () => context.push(AppRoutes.adminDashboard),
                          icon: Icons.admin_panel_settings_rounded,
                          variant: AppButtonVariant.filled,
                          isExpanded: true,
                          color: AppColors.primary,
                        ),
                      ],
                      if (user.bloodGroup == null)
                        AppButton(
                          label: 'Register as Blood Donor',
                          onPressed: () => context.push(AppRoutes.donorRegistration),
                          icon: Icons.bloodtype_rounded,
                          variant: AppButtonVariant.outlined,
                          isExpanded: true,
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, Color color, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.neutral900),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.neutral500),
        ),
      ],
    );
  }
}

class _ReliabilityRingPainter extends CustomPainter {

  _ReliabilityRingPainter({required this.score, required this.color});
  final double score;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 5.0;

    final backgroundPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);

    final sweepAngle = 2 * 3.14159 * score.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -3.14159 / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
