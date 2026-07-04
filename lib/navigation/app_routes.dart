class AppRoutes {
  AppRoutes._();

  // Root
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String roleSelection = '/role-selection';
  static const String forgotPassword = '/forgot-password';

  // Main shell
  static const String home = '/home';
  static const String donate = '/donate';
  static const String volunteer = '/volunteer';
  static const String profile = '/profile';

  // Food
  static const String foodHome = '/food';
  static const String createFood = '/food/create';
  static const String foodDetail = '/food/:id';
  static const String foodHistory = '/food/history';

  // Blood
  static const String bloodHome = '/blood';
  static const String donorRegistration = '/blood/donor-registration';
  static const String createBloodRequest = '/blood/create-request';
  static const String bloodRequestDetail = '/blood/request/:id';
  static const String bloodHistory = '/blood/history';

  // Volunteer
  static const String volunteerHome = '/volunteer-home';
  static const String createVolunteerTask = '/volunteer/create';
  static const String taskDetail = '/volunteer/task/:id';
  static const String volunteerHistory = '/volunteer/history';

  // Emergency
  static const String emergency = '/emergency';
  static const String createEmergency = '/emergency/create';
  static const String emergencyDetail = '/emergency/:id';

  // Profile
  static const String editProfile = '/profile/edit';
  static const String leaderboard = '/leaderboard';
  static const String settings = '/settings';
  static const String feedback = '/feedback';

  // Notifications
  static const String notifications = '/notifications';

  // Admin
  static const String adminDashboard = '/admin';
  static const String adminUsers = '/admin/users';
  static const String adminRequests = '/admin/requests';
}
