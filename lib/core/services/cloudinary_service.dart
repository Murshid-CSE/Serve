import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:community_care_hub/core/errors/app_exception.dart';

import 'package:community_care_hub/core/models/upload_result.dart';

class CloudinaryService {
  CloudinaryService._();

  static const String _cloudName = 'y038ti8h';
  static const String _uploadPreset = 'community-care-hub';
  static const String _uploadEndpoint = 'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  /// Upload an image to Cloudinary unsigned.
  /// Returns an UploadResult containing secure_url, public_id, and optionally delete_token.
  static Future<UploadResult> uploadImage({
    required File file,
    required String folder,
  }) async {
    int retryCount = 0;
    const int maxRetries = 1;

    while (true) {
      try {
        // 1. Validate file size (5MB check)
        final size = await file.length();
        if (size > 5 * 1024 * 1024) {
          throw const ValidationException(message: 'File size exceeds 5MB limit.');
        }

        // 2. Validate file format
        final path = file.path.toLowerCase();
        if (!path.endsWith('.jpg') &&
            !path.endsWith('.jpeg') &&
            !path.endsWith('.png') &&
            !path.endsWith('.webp')) {
          throw const ValidationException(
            message: 'Unsupported image format. Allowed formats: JPG, JPEG, PNG, WEBP.',
          );
        }

        // 3. Make the unsigned upload multipart request
        final request = http.MultipartRequest('POST', Uri.parse(_uploadEndpoint))
          ..fields['upload_preset'] = _uploadPreset
          ..fields['folder'] = folder
          ..files.add(await http.MultipartFile.fromPath('file', file.path));

        final streamedResponse = await request.send().timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw TimeoutException('Cloudinary upload timed out.'),
        );

        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode != 200 && response.statusCode != 201) {
          final errorMsg = _parseError(response.body);
          throw StorageException(message: errorMsg, code: 'cloudinary-upload-failed');
        }

        final data = json.decode(response.body) as Map<String, dynamic>;
        final secureUrl = data['secure_url'] as String?;
        final publicId = data['public_id'] as String?;
        final deleteToken = data['delete_token'] as String?;

        if (secureUrl == null || publicId == null) {
          throw const StorageException(
            message: 'Invalid response from Cloudinary.',
            code: 'cloudinary-invalid-response',
          );
        }

        return UploadResult(
          secureUrl: secureUrl,
          publicId: publicId,
          deleteToken: deleteToken,
        );
      } on SocketException catch (e) {
        if (retryCount < maxRetries) {
          retryCount++;
          await Future<void>.delayed(const Duration(seconds: 2));
          continue;
        }
        throw NetworkException(
          message: 'No internet connection. Cloudinary upload failed.',
          originalError: e,
        );
      } on TimeoutException catch (e) {
        if (retryCount < maxRetries) {
          retryCount++;
          await Future<void>.delayed(const Duration(seconds: 2));
          continue;
        }
        throw StorageException(
          message: 'Upload timed out. Please check your connection.',
          code: 'timeout',
          originalError: e,
        );
      } on AppException {
        rethrow;
      } catch (e) {
        if (retryCount < maxRetries && e is! ValidationException) {
          retryCount++;
          await Future<void>.delayed(const Duration(seconds: 2));
          continue;
        }
        throw StorageException(
          message: 'Failed to upload image to Cloudinary: $e',
          code: 'unknown',
          originalError: e,
        );
      }
    }
  }

  /// Delete an image using delete_token (only valid for 10 minutes post upload).
  /// Used for rollback on Firestore write failures.
  static Future<void> deleteByToken(String deleteToken) async {
    try {
      const deleteEndpoint = 'https://api.cloudinary.com/v1_1/$_cloudName/delete_by_token';
      final response = await http.post(
        Uri.parse(deleteEndpoint),
        body: {'token': deleteToken},
      );
      if (response.statusCode != 200) {
        debugPrint('Cloudinary deleteByToken failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('Cloudinary deleteByToken error: $e');
    }
  }

  /// Deletes a historical image. Since Cloudinary client-side API does not
  /// support deleting historical images without signed credentials (for security),
  /// this is handled via console/backend cleanup or stubbed here.
  static Future<void> deleteImage(String publicId) async {
    debugPrint('Request to delete historical Cloudinary image with public_id: $publicId');
  }

  /// Upload methods specific to application domains
  static Future<UploadResult> uploadFoodImage(File file) {
    return uploadImage(file: file, folder: 'community-care-hub/food');
  }

  static Future<UploadResult> uploadProfileImage(File file) {
    return uploadImage(file: file, folder: 'community-care-hub/profiles');
  }

  static Future<UploadResult> uploadEmergencyImage(File file) {
    return uploadImage(file: file, folder: 'community-care-hub/emergencies');
  }

  static Future<UploadResult> uploadVolunteerImage(File file) {
    return uploadImage(file: file, folder: 'community-care-hub/volunteers');
  }

  static String _parseError(String body) {
    try {
      final data = json.decode(body) as Map<String, dynamic>;
      final error = data['error'] as Map<String, dynamic>?;
      return error?['message'] as String? ?? 'Cloudinary upload failed.';
    } catch (_) {
      return 'Cloudinary upload failed.';
    }
  }
}
