class AppStrings {
  AppStrings._();

  // ── APP ──────────────────────────────────────────────────────────────
  static const String appName = 'Community Care Hub';
  static const String appTagline = 'Share Food. Donate Blood. Save Lives.';
  static const String appDescription =
      'A platform connecting food donors, blood donors, and volunteers to serve communities in need.';

  // ── AUTH ──────────────────────────────────────────────────────────────
  static const String login = 'Log In';
  static const String loginTitle = 'Welcome Back';
  static const String loginSubtitle = 'Sign in to continue making a difference';
  static const String register = 'Create Account';
  static const String registerTitle = 'Join the Community';
  static const String registerSubtitle = 'Start your journey of giving back';
  static const String signOut = 'Sign Out';
  static const String signOutConfirm = 'Are you sure you want to sign out?';
  static const String email = 'Email';
  static const String emailHint = 'Enter your email address';
  static const String password = 'Password';
  static const String passwordHint = 'Enter your password';
  static const String confirmPassword = 'Confirm Password';
  static const String confirmPasswordHint = 'Re-enter your password';
  static const String fullName = 'Full Name';
  static const String fullNameHint = 'Enter your full name';
  static const String phone = 'Phone Number';
  static const String phoneHint = 'Enter your 10-digit phone number';
  static const String forgotPassword = 'Forgot Password?';
  static const String forgotPasswordTitle = 'Reset Password';
  static const String forgotPasswordSubtitle =
      'Enter your email and we\'ll send you a reset link';
  static const String resetPasswordSent =
      'Password reset email sent. Check your inbox.';
  static const String sendResetLink = 'Send Reset Link';
  static const String dontHaveAccount = 'Don\'t have an account? ';
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String orContinueWith = 'Or continue with';
  static const String signInWithGoogle = 'Sign in with Google';
  static const String agreeToTerms = 'By continuing, you agree to our ';
  static const String termsOfService = 'Terms of Service';
  static const String andText = ' and ';
  static const String privacyPolicy = 'Privacy Policy';

  // ── AUTH ERRORS ──────────────────────────────────────────────────────
  static const String authErrorGeneric =
      'Authentication failed. Please try again.';
  static const String authErrorUserNotFound =
      'No account found with this email.';
  static const String authErrorWrongPassword =
      'Incorrect password. Please try again.';
  static const String authErrorEmailInUse =
      'This email is already registered.';
  static const String authErrorWeakPassword =
      'Password is too weak. Use at least 6 characters.';
  static const String authErrorTooManyRequests =
      'Too many attempts. Please try again later.';
  static const String authErrorAccountDisabled =
      'This account has been disabled. Contact support.';

  // ── HOME ─────────────────────────────────────────────────────────────
  static const String home = 'Home';
  static const String homeGreeting = 'Hello, ';
  static const String homeSubtitle = 'How would you like to help today?';
  static const String nearbyActivity = 'Nearby Activity';
  static const String quickActions = 'Quick Actions';
  static const String recentActivity = 'Recent Activity';
  static const String viewAll = 'View All';
  static const String impactSummary = 'Your Impact';

  // ── FOOD DONATION ────────────────────────────────────────────────────
  static const String foodDonation = 'Food Donation';
  static const String foodDonations = 'Food Donations';
  static const String donateFoodTitle = 'Donate Food';
  static const String donateFoodSubtitle =
      'Share surplus food with those in need';
  static const String createFoodDonation = 'Create Food Donation';
  static const String editFoodDonation = 'Edit Food Donation';
  static const String foodTitle = 'Food Title';
  static const String foodTitleHint = 'E.g., Rice and curry, Fresh vegetables';
  static const String foodDescription = 'Description';
  static const String foodDescriptionHint =
      'Describe the food, quantity, and any dietary info';
  static const String foodCategory = 'Category';
  static const String foodQuantity = 'Quantity';
  static const String foodQuantityHint = 'E.g., Serves 10 people';
  static const String servings = 'Servings';
  static const String servingsHint = 'Estimated number of servings';
  static const String pickupAddress = 'Pickup Address';
  static const String pickupAddressHint = 'Enter the pickup location';
  static const String pickupInstructions = 'Pickup Instructions';
  static const String pickupInstructionsHint =
      'E.g., Ring the doorbell, ask for reception';
  static const String expiryTime = 'Best Before';
  static const String expiryTimeHint = 'When should this food be picked up by?';
  static const String addFoodPhotos = 'Add Photos';
  static const String addFoodPhotosHint =
      'Add photos of the food to build trust';
  static const String contactNumber = 'Contact Number';
  static const String contactNumberHint = 'Phone number for coordination';
  static const String submitDonation = 'Submit Donation';
  static const String donationCreated = 'Food donation created successfully!';
  static const String donationUpdated = 'Donation updated successfully!';
  static const String donationDeleted = 'Donation deleted.';
  static const String claimDonation = 'Claim This Donation';
  static const String claimConfirm =
      'Are you sure you want to claim this donation?';
  static const String donationClaimed =
      'Donation claimed! Contact the donor for pickup.';
  static const String markAsPickedUp = 'Mark as Picked Up';
  static const String markAsDelivered = 'Mark as Delivered';
  static const String cancelClaim = 'Cancel Claim';

  // Food categories
  static const String categoryCooked = 'Cooked Food';
  static const String categoryRaw = 'Raw Ingredients';
  static const String categoryPackaged = 'Packaged Food';
  static const String categoryFruits = 'Fruits & Vegetables';
  static const String categoryBakery = 'Bakery Items';
  static const String categoryBeverages = 'Beverages';
  static const String categoryOther = 'Other';

  // Food statuses
  static const String foodStatusAvailable = 'Available';
  static const String foodStatusClaimed = 'Claimed';
  static const String foodStatusPickedUp = 'Picked Up';
  static const String foodStatusDelivered = 'Delivered';
  static const String foodStatusExpired = 'Expired';
  static const String foodStatusCancelled = 'Cancelled';

  // ── BLOOD DONATION ───────────────────────────────────────────────────
  static const String bloodDonation = 'Blood Donation';
  static const String bloodDonations = 'Blood Donations';
  static const String bloodRequest = 'Blood Request';
  static const String bloodRequests = 'Blood Requests';
  static const String createBloodRequest = 'Create Blood Request';
  static const String editBloodRequest = 'Edit Blood Request';
  static const String donateBloodTitle = 'Donate Blood';
  static const String donateBloodSubtitle =
      'Your blood can save up to three lives';
  static const String requestBlood = 'Request Blood';
  static const String requestBloodSubtitle =
      'Find compatible blood donors nearby';
  static const String patientName = 'Patient Name';
  static const String patientNameHint = 'Name of the patient';
  static const String hospitalName = 'Hospital Name';
  static const String hospitalNameHint = 'Hospital where blood is needed';
  static const String hospitalAddress = 'Hospital Address';
  static const String hospitalAddressHint = 'Full address of the hospital';
  static const String bloodGroup = 'Blood Group';
  static const String bloodGroupRequired = 'Required Blood Group';
  static const String unitsRequired = 'Units Required';
  static const String unitsRequiredHint = 'Number of blood units needed';
  static const String urgencyLevel = 'Urgency Level';
  static const String urgencyNormal = 'Normal';
  static const String urgencyUrgent = 'Urgent';
  static const String urgencyCritical = 'Critical';
  static const String requiredBy = 'Required By';
  static const String requiredByHint = 'Date when blood is needed';
  static const String additionalNotes = 'Additional Notes';
  static const String additionalNotesHint =
      'Any additional information for donors';
  static const String submitRequest = 'Submit Request';
  static const String requestCreated = 'Blood request created successfully!';
  static const String requestUpdated = 'Request updated successfully!';
  static const String requestDeleted = 'Request deleted.';
  static const String respondToRequest = 'I Can Donate';
  static const String respondConfirm =
      'Are you willing to donate blood for this request?';
  static const String responseRecorded =
      'Thank you! The requester will contact you.';
  static const String markAsFulfilled = 'Mark as Fulfilled';

  // Blood groups
  static const String bloodGroupAPos = 'A+';
  static const String bloodGroupANeg = 'A−';
  static const String bloodGroupBPos = 'B+';
  static const String bloodGroupBNeg = 'B−';
  static const String bloodGroupABPos = 'AB+';
  static const String bloodGroupABNeg = 'AB−';
  static const String bloodGroupOPos = 'O+';
  static const String bloodGroupONeg = 'O−';

  static const List<String> allBloodGroups = [
    bloodGroupAPos,
    bloodGroupANeg,
    bloodGroupBPos,
    bloodGroupBNeg,
    bloodGroupABPos,
    bloodGroupABNeg,
    bloodGroupOPos,
    bloodGroupONeg,
  ];

  // Blood eligibility
  static const String eligibilityAge =
      'You must be between 18 and 65 years old.';
  static const String eligibilityWeight =
      'You must weigh at least 50 kg (110 lbs).';
  static const String eligibilityInterval =
      'You must wait at least 56 days between donations.';
  static const String eligibilityHealth =
      'You must be in good general health on the day of donation.';
  static const String eligibilityDisclaimer =
      'These are general guidelines. Final eligibility is determined by the blood bank.';

  // Blood request statuses
  static const String bloodStatusOpen = 'Open';
  static const String bloodStatusFulfilled = 'Fulfilled';
  static const String bloodStatusClosed = 'Closed';
  static const String bloodStatusExpired = 'Expired';
  static const String bloodStatusEmergency = 'Emergency';

  // ── VOLUNTEER ────────────────────────────────────────────────────────
  static const String volunteer = 'Volunteer';
  static const String volunteers = 'Volunteers';
  static const String volunteerTitle = 'Volunteer';
  static const String volunteerSubtitle = 'Lend a hand to your community';
  static const String volunteerTasks = 'Volunteer Tasks';
  static const String createTask = 'Create Task';
  static const String editTask = 'Edit Task';
  static const String taskTitle = 'Task Title';
  static const String taskTitleHint = 'E.g., Food delivery, Blood drive help';
  static const String taskDescription = 'Task Description';
  static const String taskDescriptionHint =
      'Describe what volunteers will be doing';
  static const String taskType = 'Task Type';
  static const String taskLocation = 'Task Location';
  static const String taskLocationHint = 'Where the task will take place';
  static const String taskDate = 'Task Date';
  static const String taskDateHint = 'When is this task scheduled?';
  static const String taskDuration = 'Estimated Duration';
  static const String taskDurationHint = 'How long will this task take?';
  static const String volunteersNeeded = 'Volunteers Needed';
  static const String volunteersNeededHint = 'Number of volunteers required';
  static const String volunteersRegistered = 'Volunteers Registered';
  static const String submitTask = 'Submit Task';
  static const String taskCreated = 'Volunteer task created successfully!';
  static const String taskUpdated = 'Task updated successfully!';
  static const String taskDeleted = 'Task deleted.';
  static const String joinTask = 'Join Task';
  static const String joinConfirm =
      'Would you like to sign up for this volunteer task?';
  static const String joinedTask = 'You have joined this volunteer task!';
  static const String leaveTask = 'Leave Task';
  static const String leaveConfirm =
      'Are you sure you want to leave this task?';
  static const String leftTask = 'You have left this volunteer task.';
  static const String markTaskComplete = 'Mark as Complete';

  // Volunteer task types
  static const String taskTypeDelivery = 'Delivery';
  static const String taskTypeCollection = 'Collection';
  static const String taskTypeCooking = 'Cooking';
  static const String taskTypeDistribution = 'Distribution';
  static const String taskTypeDriveSupport = 'Drive Support';
  static const String taskTypeCampaign = 'Campaign';
  static const String taskTypeCleanup = 'Cleanup';
  static const String taskTypeOther = 'Other';

  // Volunteer task statuses
  static const String taskStatusOpen = 'Open';
  static const String taskStatusInProgress = 'In Progress';
  static const String taskStatusCompleted = 'Completed';
  static const String taskStatusCancelled = 'Cancelled';

  // ── EMERGENCY ────────────────────────────────────────────────────────
  static const String emergency = 'Emergency';
  static const String emergencyTitle = 'Emergency Alert';
  static const String emergencySubtitle = 'Report or respond to emergencies';
  static const String createEmergency = 'Create Emergency Alert';
  static const String emergencyType = 'Emergency Type';
  static const String emergencyDescription = 'Emergency Description';
  static const String emergencyDescriptionHint =
      'Describe the emergency situation';
  static const String emergencyLocation = 'Emergency Location';
  static const String emergencyContact = 'Emergency Contact';
  static const String emergencyContactHint = 'Contact number for this emergency';
  static const String submitEmergency = 'Send Emergency Alert';
  static const String emergencyCreated = 'Emergency alert sent!';
  static const String emergencyResolved = 'Emergency marked as resolved.';
  static const String resolveEmergency = 'Mark as Resolved';
  static const String emergencyBloodShortage = 'Blood Shortage';
  static const String emergencyFoodCrisis = 'Food Crisis';
  static const String emergencyNaturalDisaster = 'Natural Disaster';
  static const String emergencyMedical = 'Medical Emergency';
  static const String emergencyOther = 'Other Emergency';
  static const String emergencyStatusActive = 'Active';
  static const String emergencyStatusResolved = 'Resolved';
  static const String emergencyStatusExpired = 'Expired';

  // ── PROFILE ──────────────────────────────────────────────────────────
  static const String profile = 'Profile';
  static const String editProfile = 'Edit Profile';
  static const String updateProfile = 'Update Profile';
  static const String profileUpdated = 'Profile updated successfully!';
  static const String changePhoto = 'Change Photo';
  static const String myDonations = 'My Donations';
  static const String myRequests = 'My Requests';
  static const String myTasks = 'My Tasks';
  static const String impactScore = 'Impact Score';
  static const String impactScoreSubtitle =
      'Your contribution to the community';
  static const String reliabilityScore = 'Reliability';
  static const String reliabilityScoreSubtitle =
      'Based on your follow-through rate';
  static const String totalDonations = 'Total Donations';
  static const String foodDonated = 'Food Donated';
  static const String bloodDonated = 'Blood Donated';
  static const String hoursVolunteered = 'Hours Volunteered';
  static const String livesImpacted = 'Lives Impacted';
  static const String leaderboard = 'Leaderboard';
  static const String leaderboardSubtitle = 'Top contributors in your area';
  static const String rank = 'Rank';
  static const String badges = 'Badges';
  static const String badgesSubtitle = 'Achievements you\'ve earned';
  static const String settings = 'Settings';
  static const String notificationSettings = 'Notification Settings';
  static const String darkMode = 'Dark Mode';
  static const String language = 'Language';
  static const String about = 'About';
  static const String helpAndSupport = 'Help & Support';
  static const String rateApp = 'Rate This App';
  static const String shareApp = 'Share App';
  static const String deleteAccount = 'Delete Account';
  static const String deleteAccountConfirm =
      'This action is permanent and cannot be undone. All your data will be deleted.';
  static const String accountDeleted = 'Your account has been deleted.';

  // ── NOTIFICATIONS ────────────────────────────────────────────────────
  static const String notifications = 'Notifications';
  static const String noNotifications = 'No notifications yet';
  static const String noNotificationsSubtitle =
      'You\'ll see updates about your donations, requests, and tasks here.';
  static const String markAllRead = 'Mark All as Read';
  static const String clearNotifications = 'Clear All';
  static const String notificationNewDonation =
      'A new food donation is available near you!';
  static const String notificationBloodRequest =
      'Urgent blood request matching your blood group!';
  static const String notificationTaskAvailable =
      'A new volunteer task is available near you!';
  static const String notificationDonationClaimed =
      'Your food donation has been claimed!';
  static const String notificationRequestFulfilled =
      'Your blood request has been fulfilled!';
  static const String notificationTaskReminder =
      'Reminder: You have a volunteer task tomorrow.';
  static const String notificationEmergency =
      'Emergency alert in your area!';

  // ── ADMIN ────────────────────────────────────────────────────────────
  static const String admin = 'Admin';
  static const String adminDashboard = 'Admin Dashboard';
  static const String manageUsers = 'Manage Users';
  static const String manageDonations = 'Manage Donations';
  static const String manageRequests = 'Manage Requests';
  static const String manageTasks = 'Manage Tasks';
  static const String manageEmergencies = 'Manage Emergencies';
  static const String reports = 'Reports';
  static const String analytics = 'Analytics';
  static const String totalUsers = 'Total Users';
  static const String activeUsers = 'Active Users';
  static const String totalFoodDonations = 'Total Food Donations';
  static const String totalBloodRequests = 'Total Blood Requests';
  static const String totalVolunteerTasks = 'Total Volunteer Tasks';
  static const String totalEmergencies = 'Total Emergencies';
  static const String suspendUser = 'Suspend User';
  static const String suspendUserConfirm =
      'Are you sure you want to suspend this user?';
  static const String userSuspended = 'User has been suspended.';
  static const String reinstateUser = 'Reinstate User';
  static const String userReinstated = 'User has been reinstated.';
  static const String flagContent = 'Flag Content';
  static const String removeContent = 'Remove Content';
  static const String contentRemoved = 'Content has been removed.';

  // ── COMMON ───────────────────────────────────────────────────────────
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String done = 'Done';
  static const String next = 'Next';
  static const String back = 'Back';
  static const String skip = 'Skip';
  static const String submit = 'Submit';
  static const String close = 'Close';
  static const String ok = 'OK';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String search = 'Search';
  static const String searchHint = 'Search...';
  static const String filter = 'Filter';
  static const String sort = 'Sort';
  static const String refresh = 'Refresh';
  static const String loading = 'Loading...';
  static const String pleaseWait = 'Please wait...';
  static const String processing = 'Processing...';
  static const String uploading = 'Uploading...';
  static const String success = 'Success';
  static const String error = 'Error';
  static const String warning = 'Warning';
  static const String info = 'Info';
  static const String noInternet =
      'No internet connection. Please check your network and try again.';
  static const String gpsUnavailable =
      'GPS is unavailable. Please enable location services.';
  static const String locationPermissionDenied =
      'Location permission is required to find nearby donations and requests.';
  static const String cameraPermissionDenied =
      'Camera permission is required to take photos.';
  static const String storagePermissionDenied =
      'Storage permission is required to save images.';
  static const String notificationPermissionDenied =
      'Enable notifications to stay updated on donations and requests.';
  static const String permissionRequired = 'Permission Required';
  static const String openSettings = 'Open Settings';
  static const String somethingWentWrong =
      'Something went wrong. Please try again.';
  static const String sessionExpired =
      'Your session has expired. Please sign in again.';
  static const String featureComingSoon = 'This feature is coming soon!';
  static const String shareMessage =
      'Join Community Care Hub — donate food, blood, and volunteer to make a difference! Download now:';
  static const String noResultsFound = 'No results found.';
  static const String pullToRefresh = 'Pull to refresh';
  static const String selectDate = 'Select Date';
  static const String selectTime = 'Select Time';
  static const String selectLocation = 'Select Location';
  static const String useCurrentLocation = 'Use Current Location';
  static const String chooseFromGallery = 'Choose from Gallery';
  static const String takePhoto = 'Take Photo';
  static const String removePhoto = 'Remove Photo';
  static const String seeMore = 'See More';
  static const String seeLess = 'See Less';
  static const String copied = 'Copied to clipboard';
  static const String call = 'Call';
  static const String message = 'Message';
  static const String directions = 'Directions';
  static const String share = 'Share';
  static const String report = 'Report';
  static const String reportSubmitted =
      'Report submitted. We\'ll review it shortly.';
  static const String km = 'km';
  static const String away = 'away';

  // ── VALIDATION ───────────────────────────────────────────────────────
  static const String validationRequired = 'This field is required.';
  static const String validationEmail = 'Please enter a valid email address.';
  static const String validationPhone =
      'Please enter a valid 10-digit phone number.';
  static const String validationPasswordLength =
      'Password must be at least 6 characters.';
  static const String validationPasswordMatch = 'Passwords do not match.';
  static const String validationName =
      'Name must be at least 2 characters and contain only letters.';
  static const String validationQuantity =
      'Please enter a valid quantity (greater than 0).';
  static const String validationDescription =
      'Description must be at least 10 characters.';
  static const String validationTitle =
      'Title must be at least 3 characters.';
  static const String validationBloodGroup = 'Please select a blood group.';
  static const String validationLocation = 'Please select a valid location.';
  static const String validationExpiryTime =
      'Expiry time must be in the future.';
  static const String validationImage = 'Please add at least one photo.';
  static const String validationServings =
      'Please enter a valid number of servings.';
  static const String validationUnits =
      'Please enter a valid number of units.';
  static const String validationCategory = 'Please select a category.';
  static const String validationTaskType = 'Please select a task type.';
  static const String validationDate = 'Please select a valid date.';
  static const String validationFutureDate = 'Date must be in the future.';
  static const String validationVolunteersNeeded =
      'Please enter the number of volunteers needed.';

  // ── EMPTY STATES ─────────────────────────────────────────────────────
  static const String emptyFoodDonations = 'No food donations nearby';
  static const String emptyFoodDonationsSubtitle =
      'Be the first to share surplus food in your area. Tap the button below to get started.';
  static const String emptyBloodRequests = 'No blood requests nearby';
  static const String emptyBloodRequestsSubtitle =
      'There are no active blood requests in your area right now. Check back later or create one.';
  static const String emptyVolunteerTasks = 'No volunteer tasks available';
  static const String emptyVolunteerTasksSubtitle =
      'No tasks need volunteers right now. Create a task or check back soon.';
  static const String emptyEmergencies = 'No active emergencies';
  static const String emptyEmergenciesSubtitle =
      'There are no active emergency alerts in your area. That\'s great news!';
  static const String emptyMyDonations = 'You haven\'t made any donations yet';
  static const String emptyMyDonationsSubtitle =
      'Start making a difference by donating food or blood.';
  static const String emptyMyRequests = 'You haven\'t made any requests yet';
  static const String emptyMyRequestsSubtitle =
      'Create a blood request or check back later.';
  static const String emptyMyTasks = 'You haven\'t joined any tasks yet';
  static const String emptyMyTasksSubtitle =
      'Browse volunteer tasks and lend a helping hand.';
  static const String emptySearch = 'No results found';
  static const String emptySearchSubtitle =
      'Try adjusting your search or filters.';
  static const String emptyLeaderboard = 'Leaderboard is empty';
  static const String emptyLeaderboardSubtitle =
      'Start contributing to earn your spot on the leaderboard!';

  // ── ONBOARDING ───────────────────────────────────────────────────────
  static const String onboardingTitle1 = 'Share Surplus Food';
  static const String onboardingSubtitle1 =
      'Donate leftover food to nearby shelters and families in need. Reduce waste and feed the hungry.';
  static const String onboardingTitle2 = 'Donate Blood, Save Lives';
  static const String onboardingSubtitle2 =
      'Find blood requests near you and respond quickly. One donation can save up to three lives.';
  static const String onboardingTitle3 = 'Volunteer & Make an Impact';
  static const String onboardingSubtitle3 =
      'Join volunteer tasks in your community. Track your impact and climb the leaderboard.';
  static const String getStarted = 'Get Started';
}
