import 'package:community_care_hub/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signInWithEmail(String email, String password);
  Future<UserEntity> signInWithGoogle();
  Future<UserEntity> registerWithEmail(
    String name,
    String email,
    String phone,
    String password,
  );
  Future<void> signOut();
  Future<UserEntity?> getCurrentUser();
  Future<void> updateUserRole(String role);
  Stream<UserEntity?> authStateChanges();
  Future<void> updateUserProfile(Map<String, dynamic> data);
}
