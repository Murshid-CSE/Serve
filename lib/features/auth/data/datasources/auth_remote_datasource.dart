import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:community_care_hub/features/auth/domain/entities/user_entity.dart';
import 'package:community_care_hub/core/constants/firebase_constants.dart';
import 'package:community_care_hub/core/errors/app_exception.dart';

class AuthRemoteDataSource {
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Stream of Auth State Changes
  Stream<UserEntity?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((fbUser) async {
      if (fbUser == null) return null;
      return await _getUserFromFirestore(fbUser.uid);
    });
  }

  /// Get current user
  Future<UserEntity?> getCurrentUser() async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) return null;
    return await _getUserFromFirestore(fbUser.uid);
  }

  /// Sign In with Email & Password
  Future<UserEntity> signInWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException(message: 'Login failed. User is null.');
      }

      final user = await _getUserFromFirestore(credential.user!.uid);
      if (user == null) {
        // Create user document if missing (e.g. if auth exists but firestore doc was deleted)
        return await _createNewUserDocument(
          uid: credential.user!.uid,
          name: email.split('@')[0],
          email: email.trim(),
          phone: '',
        );
      }
      return user;
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  /// Sign In with Google
  Future<UserEntity> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException(message: 'Google sign-in cancelled by user.');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final fb.OAuthCredential credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final authResult = await _firebaseAuth.signInWithCredential(credential);
      if (authResult.user == null) {
        throw const AuthException(message: 'Google login failed.');
      }

      final user = await _getUserFromFirestore(authResult.user!.uid);
      if (user == null) {
        return await _createNewUserDocument(
          uid: authResult.user!.uid,
          name: googleUser.displayName ?? authResult.user!.displayName ?? 'User',
          email: googleUser.email,
          phone: authResult.user!.phoneNumber ?? '',
          photoUrl: googleUser.photoUrl ?? authResult.user!.photoURL,
        );
      }
      return user;
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  /// Register with Email & Password
  Future<UserEntity> registerWithEmail(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException(message: 'Registration failed.');
      }

      return await _createNewUserDocument(
        uid: credential.user!.uid,
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  /// Update User Role
  Future<void> updateUserRole(String role) async {
    try {
      final fbUser = _firebaseAuth.currentUser;
      if (fbUser == null) {
        throw const AuthException(message: 'User must be signed in to update role.');
      }

      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(fbUser.uid)
          .update({
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e);
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  /// Update User Profile Fields
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final fbUser = _firebaseAuth.currentUser;
      if (fbUser == null) {
        throw const AuthException(message: 'User must be signed in to update profile.');
      }

      final profileData = Map<String, dynamic>.from(data);
      profileData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(fbUser.uid)
          .update(profileData);
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e);
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  /// Helper to fetch user from Firestore
  Future<UserEntity?> _getUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .get();
      if (!doc.exists || doc.data() == null) return null;
      return UserEntity.fromMap(doc.data()!);
    } catch (e) {
      return null;
    }
  }

  /// Helper to create user document in Firestore
  Future<UserEntity> _createNewUserDocument({
    required String uid,
    required String name,
    required String email,
    required String phone,
    String? photoUrl,
  }) async {
    final user = UserEntity(
      uid: uid,
      name: name,
      email: email,
      phone: phone,
      photoUrl: photoUrl,
      role: 'donor', // default role
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      // Use set instead of update
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .set(user.toMap());
      return user;
    } on FirebaseException catch (e) {
      throw FirestoreException.fromFirebase(e);
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }
}
