import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:community_care_hub/core/errors/app_exception.dart';
import 'package:community_care_hub/core/services/cloudinary_service.dart';
import 'package:community_care_hub/core/models/upload_result.dart';

class ImageUtils {
  ImageUtils._();

  static final ImagePicker _picker = ImagePicker();

  /// Maximum file size in bytes (200KB)
  static const int maxFileSize = 200 * 1024;

  /// Pick image from camera
  static Future<File?> pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image == null) return null;
      return await _compressImage(File(image.path));
    } catch (e) {
      throw const StorageException(
        message: 'Failed to capture image. Please check camera permissions.',
        code: 'camera-error',
      );
    }
  }

  /// Pick image from gallery
  static Future<File?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image == null) return null;
      return await _compressImage(File(image.path));
    } catch (e) {
      throw const StorageException(
        message: 'Failed to pick image. Please check gallery permissions.',
        code: 'gallery-error',
      );
    }
  }

  /// Show image source picker dialog
  static Future<File?> showImagePicker(BuildContext context) async {
    // Step 1: Get the user's source selection from the bottom sheet.
    // The sheet returns an ImageSource or null (if dismissed).
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select Image Source',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: Theme.of(ctx).colorScheme.primary,
                  ),
                ),
                title: const Text('Camera'),
                subtitle: const Text('Take a new photo'),
                onTap: () {
                  Navigator.of(ctx).pop(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.photo_library_rounded,
                    color: Theme.of(ctx).colorScheme.secondary,
                  ),
                ),
                title: const Text('Gallery'),
                subtitle: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.of(ctx).pop(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );

    // Step 2: Pick the image AFTER the sheet has fully closed.
    // This eliminates the race condition where pop() resolved the
    // showModalBottomSheet future before the picker completed.
    if (source == null) return null;

    switch (source) {
      case ImageSource.camera:
        return pickFromCamera();
      case ImageSource.gallery:
        return pickFromGallery();
    }
  }

  /// Compress image to target size (<200KB)
  static Future<File> _compressImage(File file) async {
    final fileSize = await file.length();
    if (fileSize <= maxFileSize) {
      return file;
    }

    int quality = 80;
    Uint8List? compressedBytes;

    while (quality > 10) {
      final result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        quality: quality,
        minWidth: 800,
        minHeight: 800,
      );

      if (result != null && result.length <= maxFileSize) {
        compressedBytes = Uint8List.fromList(result);
        break;
      }

      quality -= 10;

      if (result != null) {
        compressedBytes = Uint8List.fromList(result);
      }
    }

    if (compressedBytes == null) {
      throw const StorageException(
        message: 'Failed to compress image.',
        code: 'compression-error',
      );
    }

    final compressedFile = File('${file.path}_compressed.jpg');
    await compressedFile.writeAsBytes(compressedBytes);
    return compressedFile;
  }

  /// Get human-readable file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Upload an image to Cloudinary and return the UploadResult
  static Future<UploadResult> uploadImage({
    required String filePath,
    required String storagePath,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw const StorageException(
          message: 'Image file does not exist.',
          code: 'file-not-found',
        );
      }
      
      // Compress the image before uploading
      final compressed = await _compressImage(file);

      // Map firebase storagePath folder to Cloudinary folder structure
      String folder = 'community-care-hub/misc';
      if (storagePath.contains('profile_images')) {
        folder = 'community-care-hub/profiles';
      } else if (storagePath.contains('food_images')) {
        folder = 'community-care-hub/food';
      }

      final result = await CloudinaryService.uploadImage(
        file: compressed,
        folder: folder,
      );
      return result;
    } catch (e) {
      if (e is AppException) rethrow;
      throw StorageException(
        message: e.toString(),
        code: 'upload-error',
      );
    }
  }
}
