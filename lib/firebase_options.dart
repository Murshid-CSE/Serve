// ═══════════════════════════════════════════════════════════════════════════════
// FIREBASE OPTIONS — PLACEHOLDER FILE
// ═══════════════════════════════════════════════════════════════════════════════
//
// THIS FILE IS A PLACEHOLDER. You MUST replace it with the real file generated
// by running: flutterfire configure
//
// SETUP INSTRUCTIONS:
// ══════════════════════════════════════════════════════════════════════════════
//
// STEP 1: Create a Firebase Project
//   1. Go to https://console.firebase.google.com/
//   2. Click "Create a project" (or "Add project")
//   3. Enter project name: "community-care-hub"
//   4. Disable Google Analytics (not needed for free plan)
//   5. Click "Create project"
//
// STEP 2: Enable Firebase Services
//   A. Authentication:
//      1. Go to Authentication → Sign-in method
//      2. Enable "Email/Password" provider
//      3. Enable "Google" provider
//         - Set project support email
//         - Note the Web client ID
//
//   B. Cloud Firestore:
//      1. Go to Firestore Database → Create database
//      2. Select "Start in test mode" (we'll add rules later)
//      3. Choose nearest location (asia-south1 for India)
//
//   C. Firebase Storage:
//      1. Go to Storage → Get started
//      2. Start in test mode
//      3. Choose same location as Firestore
//
//   D. Cloud Messaging:
//      1. FCM is enabled by default
//      2. No additional setup needed
//
// STEP 3: Add Android App to Firebase
//   1. Go to Project Settings → General → Your apps
//   2. Click Android icon to add Android app
//   3. Android package name: com.communitycarecarehub.community_care_hub
//   4. App nickname: Community Care Hub
//   5. Debug signing certificate SHA-1:
//      Run in terminal: keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
//      Copy the SHA-1 fingerprint
//   6. Click "Register app"
//   7. Download google-services.json
//   8. Place google-services.json in: android/app/google-services.json
//
// STEP 4: Install FlutterFire CLI and Configure
//   Run these commands in your project root:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure --project=community-care-hub
//
//   This will:
//   - Generate this file with real values
//   - Update android/app/google-services.json
//   - Configure all Firebase services
//
// STEP 5: Deploy Firestore Security Rules
//   1. Install Firebase CLI: npm install -g firebase-tools
//   2. Run: firebase login
//   3. Run: firebase init firestore (select your project)
//   4. Copy the security rules from firestore.rules file
//   5. Run: firebase deploy --only firestore:rules
//
// STEP 6: Create Firestore Indexes
//   Deploy indexes from firestore.indexes.json:
//   firebase deploy --only firestore:indexes
//
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web platform is not supported.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS platform is not configured.');
      case TargetPlatform.macOS:
        throw UnsupportedError('macOS platform is not configured.');
      case TargetPlatform.windows:
        throw UnsupportedError('Windows platform is not configured.');
      case TargetPlatform.linux:
        throw UnsupportedError('Linux platform is not configured.');
      default:
        throw UnsupportedError('${defaultTargetPlatform.name} is not supported.');
    }
  }

  // ╔══════════════════════════════════════════════════════════════════╗
  // ║  REPLACE ALL VALUES BELOW WITH YOUR ACTUAL FIREBASE CONFIG     ║
  // ║  Run: flutterfire configure --project=YOUR_PROJECT_ID          ║
  // ╚══════════════════════════════════════════════════════════════════╝

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBJBSdlHmOJj2b1iNDqaE7moPpQDNLcrDs',
    appId: '1:304339338811:android:7c62cfc73d963bed2fbe1e',
    messagingSenderId: '304339338811',
    projectId: 'community-care-hub',
    storageBucket: 'community-care-hub.firebasestorage.app',
  );
}
