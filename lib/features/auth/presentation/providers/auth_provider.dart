import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_care_hub/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:community_care_hub/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:community_care_hub/features/auth/domain/entities/user_entity.dart';
import 'package:community_care_hub/features/auth/domain/repositories/auth_repository.dart';
import 'package:community_care_hub/core/constants/firebase_constants.dart';

// DataSource provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource();
});

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

// Auth state stream provider
final authStateProvider = StreamProvider<fb.User?>((ref) {
  return fb.FirebaseAuth.instance.authStateChanges();
});

// Current user provider - fetches full user entity from Firestore
final currentUserProvider = StreamProvider<UserEntity?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return FirebaseFirestore.instance
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .snapshots()
          .map((doc) {
        if (!doc.exists || doc.data() == null) return null;
        return UserEntity.fromMap(doc.data()!);
      });
    },
    loading: () => Stream.value(null),
    error: (_, _) => Stream.value(null),
  );
});

// Auth actions provider for login/register/signout
final authActionsProvider = Provider<AuthActions>((ref) {
  return AuthActions(ref.watch(authRepositoryProvider));
});

class AuthActions {
  final AuthRepository _repository;
  
  AuthActions(this._repository);
  
  Future<UserEntity> signInWithEmail(String email, String password) {
    return _repository.signInWithEmail(email, password);
  }
  
  Future<UserEntity> signInWithGoogle() {
    return _repository.signInWithGoogle();
  }
  
  Future<UserEntity> registerWithEmail(
    String name, String email, String phone, String password,
  ) {
    return _repository.registerWithEmail(name, email, phone, password);
  }
  
  Future<void> signOut() {
    return _repository.signOut();
  }
  
  Future<void> updateUserRole(String role) {
    return _repository.updateUserRole(role);
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) {
    return _repository.updateUserProfile(data);
  }
}
