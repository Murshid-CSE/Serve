import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:community_care_hub/features/auth/domain/entities/user_entity.dart';
import 'package:community_care_hub/features/auth/domain/repositories/auth_repository.dart';
import 'package:community_care_hub/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:community_care_hub/core/errors/app_exception.dart';

class AuthRepositoryImpl implements AuthRepository {

  AuthRepositoryImpl(this._remoteDataSource);
  final AuthRemoteDataSource _remoteDataSource;
  final Connectivity _connectivity = Connectivity();

  Future<void> _checkConnectivity() async {
    final status = await _connectivity.checkConnectivity();
    if (status.contains(ConnectivityResult.none)) {
      throw const NetworkException();
    }
  }

  @override
  Stream<UserEntity?> authStateChanges() {
    return _remoteDataSource.authStateChanges;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      return await _remoteDataSource.getCurrentUser();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserEntity> signInWithEmail(String email, String password) async {
    await _checkConnectivity();
    try {
      return await _remoteDataSource.signInWithEmail(email, password);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    await _checkConnectivity();
    try {
      return await _remoteDataSource.signInWithGoogle();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<UserEntity> registerWithEmail(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    await _checkConnectivity();
    try {
      return await _remoteDataSource.registerWithEmail(name, email, phone, password);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _remoteDataSource.signOut();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<void> updateUserRole(String role) async {
    await _checkConnectivity();
    try {
      await _remoteDataSource.updateUserRole(role);
    } on AppException {
      rethrow;
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }

  @override
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    await _checkConnectivity();
    try {
      await _remoteDataSource.updateUserProfile(data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw FirestoreException(message: e.toString());
    }
  }
}
