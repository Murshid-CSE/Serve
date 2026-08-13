# Regression Checklist

Whenever making architectural changes (like migrating to Streams or updating security rules) for one module, it is critical to verify that global systems have not accidentally broken.

Run through this checklist after deploying changes to *any* module.

## 1. Authentication & Profile
- [ ] User can log out and log back in (Google Sign-In & Email).
- [ ] Profile screen correctly loads user metadata.
- [ ] Editing profile details (Name, Phone) saves correctly.
- [ ] Cloudinary Image Upload for Profile Picture succeeds.

## 2. Leaderboard & Scoring
- [ ] Leaderboard loads successfully without index errors.
- [ ] Completing a task (e.g., Food Donation) correctly increments the user's impact score.
- [ ] Score instantly reflects on the Profile screen.

## 3. Global Infrastructure
- [ ] Push Notifications (FCM) still trigger when actions occur (e.g., Volunteer accepts a task).
- [ ] Offline caching works: disabling Wi-Fi and opening the app displays cached data instead of endless loading spinners.
- [ ] Settings screen preferences remain saved locally (SharedPreferences).
- [ ] Navigation routing functions without "Page Not Found" errors.
