import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_care_hub/navigation/app_routes.dart';
import 'package:community_care_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:community_care_hub/features/auth/presentation/screens/splash_screen.dart';
import 'package:community_care_hub/features/auth/presentation/screens/login_screen.dart';
import 'package:community_care_hub/features/auth/presentation/screens/register_screen.dart';
import 'package:community_care_hub/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:community_care_hub/features/home/presentation/screens/home_screen.dart';
import 'package:community_care_hub/features/food/presentation/screens/food_home_screen.dart';
import 'package:community_care_hub/features/food/presentation/screens/create_food_screen.dart';
import 'package:community_care_hub/features/food/presentation/screens/food_detail_screen.dart';
import 'package:community_care_hub/features/food/presentation/screens/food_history_screen.dart';
import 'package:community_care_hub/features/blood/presentation/screens/blood_home_screen.dart';
import 'package:community_care_hub/features/blood/presentation/screens/donor_registration_screen.dart';
import 'package:community_care_hub/features/blood/presentation/screens/create_blood_request_screen.dart';
import 'package:community_care_hub/features/blood/presentation/screens/blood_request_detail_screen.dart';
import 'package:community_care_hub/features/blood/presentation/screens/blood_history_screen.dart';
import 'package:community_care_hub/features/volunteer/presentation/screens/volunteer_home_screen.dart';
import 'package:community_care_hub/features/volunteer/presentation/screens/task_detail_screen.dart';
import 'package:community_care_hub/features/volunteer/presentation/screens/volunteer_history_screen.dart';
import 'package:community_care_hub/features/volunteer/presentation/screens/create_volunteer_task_screen.dart';
import 'package:community_care_hub/features/emergency/presentation/screens/emergency_screen.dart';
import 'package:community_care_hub/features/emergency/presentation/screens/create_emergency_screen.dart';
import 'package:community_care_hub/features/emergency/presentation/screens/emergency_detail_screen.dart';
import 'package:community_care_hub/features/profile/presentation/screens/profile_screen.dart';
import 'package:community_care_hub/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:community_care_hub/features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'package:community_care_hub/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:community_care_hub/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:community_care_hub/features/admin/presentation/screens/admin_users_screen.dart';
import 'package:community_care_hub/features/admin/presentation/screens/admin_requests_screen.dart';
import 'package:community_care_hub/features/home/presentation/screens/main_shell_screen.dart';
import 'package:community_care_hub/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:community_care_hub/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:community_care_hub/features/profile/presentation/screens/settings_screen.dart';
import 'package:community_care_hub/features/profile/presentation/screens/feedback_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isLoggedIn = authState.valueOrNull != null;
      final currentPath = state.matchedLocation;

      // Public routes that don't require auth
      const publicRoutes = [
        AppRoutes.splash,
        AppRoutes.onboarding,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.forgotPassword,
      ];

      final isPublicRoute = publicRoutes.contains(currentPath);

      // If not logged in and trying to access a protected route, redirect to login
      if (!isLoggedIn && !isPublicRoute) {
        return AppRoutes.login;
      }

      // If logged in and trying to access login/register, redirect to home
      if (isLoggedIn && (currentPath == AppRoutes.login || currentPath == AppRoutes.register)) {
        return AppRoutes.home;
      }

      // Admin route protection — check role from Firestore user
      if (currentPath.startsWith('/admin')) {
        final user = ref.read(currentUserProvider).valueOrNull;
        if (user == null || !user.isAdmin) {
          return AppRoutes.home;
        }
      }

      return null; // No redirect needed
    },
    routes: [
      // Auth routes
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => _buildPageWithFade(
          state,
          const SplashScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) => _buildPageWithFade(
          state,
          const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (context, state) => _buildPageWithSlide(
          state,
          const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => _buildPageWithSlide(
          state,
          const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (context, state) => _buildPageWithSlide(
          state,
          const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        pageBuilder: (context, state) => _buildPageWithSlide(
          state,
          const RoleSelectionScreen(),
        ),
      ),

      // Main shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainShellScreen(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) => _buildPageWithFade(
              state,
              const HomeScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.donate,
            pageBuilder: (context, state) => _buildPageWithFade(
              state,
              const FoodHomeScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.volunteer,
            pageBuilder: (context, state) => _buildPageWithFade(
              state,
              const VolunteerHomeScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) => _buildPageWithFade(
              state,
              const ProfileScreen(),
            ),
          ),
        ],
      ),

      // Food routes
      GoRoute(
        path: AppRoutes.foodHome,
        pageBuilder: (context, state) => _buildPageWithSlide(
          state,
          const FoodHomeScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.createFood,
        pageBuilder: (context, state) => _buildPageWithSlide(
          state,
          const CreateFoodScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.foodDetail,
        pageBuilder: (context, state) => _buildPageWithSlide(
          state,
          FoodDetailScreen(donationId: state.pathParameters['id'] ?? ''),
        ),
      ),
      GoRoute(
        path: AppRoutes.foodHistory,
        pageBuilder: (context, state) => _buildPageWithSlide(
          state,
          const FoodHistoryScreen(),
        ),
      ),

      // Blood routes
      GoRoute(
        path: AppRoutes.bloodHome,
        pageBuilder: (context, state) => _buildPageWithSlide(
          state,
          const BloodHomeScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.donorRegistration,
        pageBuilder: (context, state) => _buildPageWithSlide(
          state,
          const DonorRegistrationScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.createBloodRequest,
        pageBuilder: (context, state) => _buildPageWithSlide(
          state,
          const CreateBloodRequestScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.bloodRequestDetail,
        pageBuilder: (context, state) => _buildPageWithSlide(
          state,
          BloodRequestDetailScreen(requestId: state.pathParameters['id'] ?? ''),
        ),
      ),
      GoRoute(
        path: AppRoutes.bloodHistory,
        pageBuilder: (context, state) => _buildPageWithSlide(
          state,
          const BloodHistoryScreen(),
        ),
      ),

      // Volunteer routes
      GoRoute(
        path: AppRoutes.volunteerHome,
        pageBuilder: (context, state) => _buildPageWithSlide(
          state,
          const VolunteerHomeScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.taskDetail,
        pageBuilder: (context, state) => _buildPageWithSlide(
          state,
          TaskDetailScreen(taskId: state.pathParameters['id'] ?? ''),
        ),
      ),
      GoRoute(
        path: AppRoutes.volunteerHistory,
        pageBuilder: (context, state) => _buildPageWithSlide(
          state,
          const VolunteerHistoryScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.createVolunteerTask,
        pageBuilder: (context, state) => _buildPageWithSlide(
          state,
          const CreateVolunteerTaskScreen(),
        ),
      ),

      // Emergency routes
      GoRoute(
        path: AppRoutes.emergency,
        pageBuilder: (context, state) => _buildPageWithSlide(
          state,
          const EmergencyScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.createEmergency,
        pageBuilder: (context, state) => _buildPageWithSlide(
          state,
          const CreateEmergencyScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.emergencyDetail,
        pageBuilder: (context, state) => _buildPageWithSlide(
          state,
          EmergencyDetailScreen(emergencyId: state.pathParameters['id'] ?? ''),
        ),
      ),

      // Profile routes
      GoRoute(
        path: AppRoutes.editProfile,
        pageBuilder: (context, state) => _buildPageWithSlide(
          state,
          const EditProfileScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.leaderboard,
        pageBuilder: (context, state) => _buildPageWithSlide(
          state,
          const LeaderboardScreen(),
        ),
      ),

      // Notifications
      GoRoute(
        path: AppRoutes.notifications,
        pageBuilder: (context, state) => _buildPageWithSlide(
          state,
          const NotificationsScreen(),
        ),
      ),

      // Admin routes
      GoRoute(
        path: AppRoutes.adminDashboard,
        pageBuilder: (context, state) => _buildPageWithSlide(
          state,
          const AdminDashboardScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.adminUsers,
        pageBuilder: (context, state) => _buildPageWithSlide(
          state,
          const AdminUsersScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.adminRequests,
        pageBuilder: (context, state) => _buildPageWithSlide(
          state,
          const AdminRequestsScreen(),
        ),
      ),

      // Settings & Feedback
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (context, state) => _buildPageWithSlide(
          state,
          const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.feedback,
        pageBuilder: (context, state) => _buildPageWithSlide(
          state,
          const FeedbackScreen(),
        ),
      ),
    ],
    errorPageBuilder: (context, state) => MaterialPage(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Page Not Found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'The page you are looking for does not exist.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.go(AppRoutes.home),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
});

Page<void> _buildPageWithFade(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

Page<void> _buildPageWithSlide(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slideAnimation = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurveTween(curve: Curves.easeInOut).animate(animation));

      final fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurveTween(curve: Curves.easeIn).animate(animation));

      return SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}
