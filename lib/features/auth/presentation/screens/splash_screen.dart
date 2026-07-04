import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:community_care_hub/navigation/app_routes.dart';
import 'package:community_care_hub/core/constants/app_colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Wait for the animation to play
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    // Check if onboarding was completed
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    // First check Firebase Auth state (locally cached — resolves instantly)
    final authState = ref.read(authStateProvider);
    final firebaseUser = authState.valueOrNull;

    if (firebaseUser == null) {
      // Not authenticated — go to onboarding or login
      if (mounted) {
        if (hasSeenOnboarding) {
          context.go(AppRoutes.login);
        } else {
          context.go(AppRoutes.onboarding);
        }
      }
      return;
    }

    // Firebase Auth confirms a user exists. Now wait for the Firestore
    // user document to load (with a timeout to prevent infinite waiting).
    try {
      final userEntity = await ref
          .read(currentUserProvider.future)
          .timeout(const Duration(seconds: 5));

      if (!mounted) return;

      if (userEntity != null) {
        if (userEntity.role == 'donor' ||
            userEntity.role == 'volunteer' ||
            userEntity.role == 'both' ||
            userEntity.role == 'admin') {
          context.go(AppRoutes.home);
        } else {
          context.go(AppRoutes.roleSelection);
        }
      } else {
        context.go(AppRoutes.roleSelection);
      }
    } catch (_) {
      // Timeout or error — fall back to login
      if (mounted) context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.heroGradient,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    size: 80,
                    color: AppColors.primary,
                  ),
                )
                    .animate()
                    .scale(
                      duration: 800.ms,
                      curve: Curves.bounceOut,
                      begin: const Offset(0, 0),
                      end: const Offset(1, 1),
                    )
                    .then()
                    .shake(duration: 400.ms, hz: 4),

                const SizedBox(height: 32),

                // App Name
                Text(
                  'Community Care Hub',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 500.ms)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),

                const SizedBox(height: 16),

                // Tagline
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'One Platform. One Community. One Coordinated Workflow.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 1100.ms, duration: 800.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
              ],
            ),

            // Footer Authors
            Positioned(
              bottom: 48,
              child: Column(
                children: [
                  Text(
                    'CIT Chennai — Dept of CSE',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white38,
                          letterSpacing: 0.8,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'By Murshid S & Mohamed Arsath M',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white54,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(delay: 1600.ms, duration: 600.ms),
            ),
          ],
        ),
      ),
    );
  }
}
